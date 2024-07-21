defmodule FlopContext do
  @moduledoc """
  The entrypoint for defining your Context interface.

  This can be used in the application as:

      use FlopContext,
        queries: Queries.ExecutionFlopQueries,
        schema: Schemas.Execution,
        singular: :execution,
        plural: :executions

  As result, you will get the following functions in your module:

  - `list_executions(criteria \\ [])`
  - `get_execution(id, criteria \\ [])`
  - `get_execution!(id, criteria \\ [])`
  - `change_execution(record, attrs \\ %{})`

  `criteria` is using `Flop` to filter and paginate data, and it exposes a way to join, preload assocs.

  ## Filter in IEx

  Usually it is more convenient to work with keyword lists, and have a shorter notation.

      # Will produce a `WHERE field_name='value'` query
      iex> list_executions(filters: [field_name: "value"])

  Paginate records

      # Will produce a `LIMIT 10 OFFSET 10` query
      iex> list_executions(page: 2, page_size: 10)

  Join records

      # Will produce a `JOIN users ON` query
      iex> list_executions(join: [:users])

  Order records

      # Will produce a `ORDER BY field_name DESC` query
      iex> list_executions(order_by: [:field_name], order_directions: [:desc])

  Restrict fields that can be filtered on

      # Will produce a query without `field_name`
      iex> list_executions(filters: [field_name: "value"], allowed_fields: [:other_field])

  ## Filter using params from user

  It works mostly the same way, except that `[:filters, :page, :page_size, :order_by, :order_directions]`
  can come in params as a map.

  You should use it in a combination with `allowed_fields` to restrict what the user can filter on.

  Filters as list of maps.

      # Will produce a `WHERE field_name='value'` query
      iex> list_executions(%{"filters" => [%{"field" => "field_name", "op" => "==", "value" => value"}])

  Paginate records

      # Will produce a `LIMIT 10 OFFSET 10` query
      iex> list_executions(%{"page" => 2, "page_size" => 10})

  Order records

      # Will produce a `ORDER BY field_name DESC` query
      iex> list_executions(%{"order_by" => ["field_name"], "order_directions" => ["desc"]})

  Restrict fields that can be filtered on

      # Will produce a query without `field_name`
      iex> list_executions(%{"filters" => [%{"field" => "field_name", "op" => "==", "value" => value"}], allowed_fields: [:other_field])

  ## Flop metadata

    In criteria you can pass `flop: true` to get a `{records, flop_meta}` response.

    iex> list_executions(%{"page" => 2, "page_size" => 10}, flop: true)

  ## Log level
    In criteria you can pass `log: false` or can be any `Logger.level/0`

    Disable log:
    iex> list_executions(log: false)

    Change log level for query:
    iex> list_executions(log: :warn)

  ## Invalid query

    If you use fields that are not configured for the schema, you will get a `{:error, meta}` as response.

    iex> list_executions(filters: [:wrong_field: 1])

  ## get_* functions

  Besides the obvious of passing in the `id`, as second parameter you can also pass `criteria` from above. It will remove ordering.
  """

  def context(queries_module, schema_module, singular_form, plural_form) do
    quote do
      schema_module_name = unquote(schema_module) |> Module.split() |> Enum.reverse() |> hd()
      repo = Application.compile_env(:flop_context, :repo) || raise "No repo for Flop"

      alias Ecto.Multi

      alias unquote(queries_module)
      alias unquote(schema_module)

      @doc """
      Returns the list of #{unquote(plural_form)}.
      Optional filters can be passed as a list of tuples.

      ## Examples

          iex> list_#{unquote(plural_form)}()
          [%#{schema_module_name}{}, ...]

          iex> list_#{unquote(plural_form)}(some_criteria: "test")
          [%#{schema_module_name}{}, ...]

      """
      def unquote(:"list_#{plural_form}")(criteria \\ %{})

      def unquote(:"list_#{plural_form}")(criteria) when is_list(criteria) do
        unquote(:"list_#{plural_form}")(Map.new(criteria))
      end

      def unquote(:"list_#{plural_form}")(criteria) when is_map(criteria) do
        {flop_response, criteria} = Map.pop(criteria, :flop, false)
        {log_response, criteria} = Map.pop(criteria, :log, true)

        with query <- unquote(queries_module).with_query(criteria),
             {:ok, %Flop{} = flop} <- unquote(queries_module).with_flop(criteria, flop_response),
             query <- Flop.with_named_bindings(query, flop, &unquote(queries_module).join_assocs/2, for: unquote(schema_module)) do
          unquote(:"do_list_#{plural_form}")(query, criteria, flop, flop_response, log_response)
        end
      end

      def unquote(:"list_#{plural_form}")(params, extras) when is_map(params) and is_list(extras) do
        criteria = Map.merge(params, Map.new(extras))
        unquote(:"list_#{plural_form}")(criteria)
      end

      defp unquote(:"do_list_#{plural_form}")(query, _criteria, flop, true, _log) do
        Flop.run(query, flop, for: unquote(schema_module))
      end

      defp unquote(:"do_list_#{plural_form}")(query, criteria, flop, false, log) do
        query
        |> Flop.query(flop, for: unquote(schema_module))
        |> unquote(queries_module).maybe_remove_limit_and_offset(criteria)
        |> repo.all(log: log)
      end

      @doc """
      Gets a single `%#{schema_module_name}{}`.

      Returns `nil` if no record was found.

      ## Examples

          iex> get_#{unquote(singular_form)}!(123)
          %#{schema_module_name}{}

          iex> get_#{unquote(singular_form)}!(456)
          nil

      """
      def unquote(:"get_#{singular_form}")(id) do
        unquote(:"get_#{singular_form}")(id, %{})
      end

      def unquote(:"get_#{singular_form}")(id, criteria) when is_list(criteria) do
        unquote(:"get_#{singular_form}")(id, Map.new(criteria))
      end

      def unquote(:"get_#{singular_form}")(id, criteria) when is_map(criteria) do
        {flop_response, criteria} = Map.pop(criteria, :flop, false)

        with query <- unquote(queries_module).with_query(criteria),
             {:ok, %Flop{} = flop} <- unquote(queries_module).with_flop(criteria, flop_response),
             flop <- Flop.reset_order(flop),
             query <- Flop.with_named_bindings(query, flop, &unquote(queries_module).join_assocs/2, for: unquote(schema_module)) do
          query
          |> Flop.query(flop, for: unquote(schema_module))
          |> repo.get(id)
        end
      end

      @doc """
      Gets a single `%#{schema_module_name}{}`.

      Raises `Ecto.NoResultsError` if no record was found.

      ## Examples

          iex> get_#{unquote(singular_form)}!(123)
          %#{schema_module_name}{}

          iex> get_#{unquote(singular_form)}!(456)
          ** (Ecto.NoResultsError)

      """
      def unquote(:"get_#{singular_form}!")(id) do
        unquote(:"get_#{singular_form}!")(id, %{})
      end

      def unquote(:"get_#{singular_form}!")(id, criteria) when is_list(criteria) do
        unquote(:"get_#{singular_form}!")(id, Map.new(criteria))
      end

      def unquote(:"get_#{singular_form}!")(id, criteria) when is_map(criteria) do
        {flop_response, criteria} = Map.pop(criteria, :flop, false)

        with query <- unquote(queries_module).with_query(criteria),
             {:ok, %Flop{} = flop} <- unquote(queries_module).with_flop(criteria, flop_response),
             flop <- Flop.reset_order(flop),
             query <- Flop.with_named_bindings(query, flop, &unquote(queries_module).join_assocs/2, for: unquote(schema_module)) do
          query
          |> Flop.query(flop, for: unquote(schema_module))
          |> repo.get!(id)
        end
      end

      @doc """
      Gets a single `%#{schema_module_name}{}` based on criteria.

      Returns `nil` if no record was found.

      ## Examples

          iex> one_#{unquote(singular_form)}!(criteria)
          %#{schema_module_name}{}

          iex> one_#{unquote(singular_form)}!(criteria)
          nil

      """
      def unquote(:"one_#{singular_form}")(criteria) when is_list(criteria) do
        unquote(:"one_#{singular_form}")(Map.new(criteria))
      end

      def unquote(:"one_#{singular_form}")(criteria) when is_map(criteria) do
        {flop_response, criteria} = Map.pop(criteria, :flop, false)

        with query <- unquote(queries_module).with_query(criteria),
             {:ok, %Flop{} = flop} <- unquote(queries_module).with_flop(criteria, flop_response),
             flop <- Flop.reset_order(flop),
             query <- Flop.with_named_bindings(query, flop, &unquote(queries_module).join_assocs/2, for: unquote(schema_module)) do
          query
          |> Flop.query(flop, for: unquote(schema_module))
          |> repo.one()
        end
      end

      @doc """
      Returns an `%Ecto.Changeset{}` for tracking #{unquote(singular_form)} changes.

      ## Examples

          iex> change_#{unquote(singular_form)}(#{unquote(singular_form)})
          %Ecto.Changeset{data: %#{schema_module_name}{}}

      """
      def unquote(:"change_#{singular_form}")(%unquote(schema_module){} = record, attrs \\ %{}) do
        unquote(schema_module).changeset(record, attrs)
      end
    end
  end

  defmacro __using__(opts \\ []) do
    apply(__MODULE__, :context, [opts[:queries], opts[:schema], opts[:singular], opts[:plural]])
  end
end
