defmodule FlopQueries do
  @moduledoc """
  This module serves as the entry point for defining the interface for Ecto queries used in contexts.

  Features provided by this module:

  1. A mechanism for preparing Ecto queries for use with Flop. This mechanism is capable of handling `:join`, `:preload`, and `:select` options.
  1.1. A method for handling any custom options that may be required, such as scoping the query by `:user`.
       To use this method, you must define a `def with_option(query, {:user, user})` function in the module where `FlopQueries` is used.
       Atom keys must be used for custom options, whereas string keys will be skipped.
  2. A function for preparing `Flop` via the `with_flop` method.

  Please note that if you are using the `:join` option, the module where `FlopQueries` is included must also implement the `def join_assocs` callbacks.

  These functions are typically used automatically in the `FlopContext`.

  To use this module in an application, include the following line:

      use FlopQueries, schema: Workflow
  """

  def queries(schema_module, except) do
    quote do
      import Ecto.Query

      @flop_keys [:filters, :page, :page_size, :order_by, :order_directions]
                 |> Enum.flat_map(&[&1, to_string(&1)])
      @internal_keys [:join, :preload, :select, :flop] |> Enum.flat_map(&[&1, to_string(&1)])

      alias unquote(schema_module)

      def with_query(criteria \\ %{}) do
        base()
        |> with_query(criteria)
      end

      def with_query(query, criteria) do
        query
        |> apply_joins(criteria)
        |> apply_preloads(criteria)
        |> apply_selects(criteria)
        |> apply_options(criteria)
      end

      defp apply_options(query, criteria) do
        options =
          criteria
          |> Map.drop(@flop_keys ++ @internal_keys)
          |> Map.filter(fn {k, _v} -> is_atom(k) end)

        options
        |> Enum.reduce(query, fn
          option, query_acc -> with_option(query_acc, option)
        end)
      end

      def with_option(query, {:allowed_fields, _}) do
        query
      end

      defp apply_joins(query, criteria) do
        joins = Map.get(criteria, :join, [])

        joins
        |> Enum.reduce(query, fn
          join, query_acc -> join_assocs(query_acc, join)
        end)
      end

      defp apply_preloads(query, criteria) do
        preloads = Map.get(criteria, :preload, [])

        preloads
        |> Enum.reduce(query, fn
          preload, query_acc ->
            preload(query_acc, [binding_name], ^preload)
        end)
      end

      defp apply_selects(query, criteria) do
        selects = Map.get(criteria, :select, [])

        case selects do
          [] -> select(query, [binding_name], binding_name)
          _ -> select(query, [binding_name], ^selects)
        end
      end

      def with_flop(criteria, flop_response) do
        flop_params =
          criteria
          |> Map.take(@flop_keys)
          |> Map.new(fn
            {k, v} when is_binary(k) -> {String.to_existing_atom(k), v}
            {k, v} -> {k, v}
          end)

        flop_params = Map.update(flop_params, :filters, [], &transform_flop_filters(&1, flop_response))

        allowed_fields = Map.get(criteria, :allowed_fields, :all)

        with {:ok, %Flop{} = flop} <- Flop.validate(flop_params, for: unquote(schema_module)),
             {:ok, %Flop{} = flop} <- take_allowed_fields(flop, allowed_fields) do
          {:ok, flop}
        end
      end

      # Converts keyword list values like `[name: "Bob"]` into full Flop filters like `%{field: field, op: :==, value: value}`
      #
      # When in Flop mode (`flop_response` == true):
      # - Empty values in the filters are ignored, as it is assumed that they correspond to form fields that were not filled.
      #
      # When not in Flop mode (`flop_response` == false):
      # - Filters with empty strings (`""`) are respected and included in the SQL query.
      # - Filters with `nil` values are also included in the SQL query.
      defp transform_flop_filters(filters, flop_response)

      defp transform_flop_filters(filters, true = _flop_response) when is_list(filters) do
        filters
        |> Enum.map(fn
          {field, value} ->
            %{field: field, op: :==, value: value}

          filter when is_map(filter) ->
            filter
        end)
      end

      defp transform_flop_filters(filters, false = _flop_response) when is_list(filters) do
        filters
        |> Enum.map(fn
          {field, nil} ->
            %{field: field, op: :empty, value: true}

          {field, ""} ->
            %{field: field, op: :in, value: [""]}

          {field, value} ->
            %{field: field, op: :==, value: value}

          filter when is_map(filter) ->
            filter
        end)
      end

      defp transform_flop_filters(filters, _is_flop_mode), do: filters

      def maybe_remove_limit_and_offset(query, criteria) do
        criteria_keys = Map.keys(criteria)

        keys_to_keep_limit_and_offset = [:page, :page_size, :flop] |> Enum.flat_map(&[&1, to_string(&1)])

        intersection =
          MapSet.intersection(
            MapSet.new(criteria_keys),
            MapSet.new(keys_to_keep_limit_and_offset)
          )

        case MapSet.size(intersection) do
          0 -> Ecto.Query.exclude(query, :limit) |> Ecto.Query.exclude(:offset)
          _ -> query
        end
      end

      defp take_allowed_fields(flop, :all), do: {:ok, flop}

      defp take_allowed_fields(flop, allowed_fields) do
        order_zip = Enum.zip(List.wrap(flop.order_by), List.wrap(flop.order_directions))

        cleaned_order_zip = Enum.filter(order_zip, fn {field, _order_direction} -> field in allowed_fields end)

        cleaned_order_by = Enum.map(cleaned_order_zip, fn {field, _order_direction} -> field end)

        cleaned_order_directions = Enum.map(cleaned_order_zip, fn {_field, order_direction} -> order_direction end)

        cleaned_filters = Flop.Filter.take(flop.filters, allowed_fields)

        cleaned_flop = %{
          flop
          | filters: cleaned_filters,
            order_by: cleaned_order_by,
            order_directions: cleaned_order_directions
        }

        {:ok, cleaned_flop}
      end

      if :base not in unquote(except) do
        defp base do
          [name | _] = Module.split(unquote(schema_module)) |> Enum.reverse()
          binding_name = Macro.underscore(name) |> String.to_atom()

          from(_ in unquote(schema_module), as: ^binding_name)
        end
      end
    end
  end

  defmacro __using__(opts) do
    schema_module = Keyword.get(opts, :schema, nil)
    except = Keyword.get(opts, :except, [])
    apply(__MODULE__, :queries, [schema_module, except])
  end
end
