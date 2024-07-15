defmodule FlopContext.Schemas.User do
  use Ecto.Schema

  @derive {
    Flop.Schema,
    filterable: [:name],
    sortable: [:name, :age],
    default_pagination_type: :page
  }

  schema "users" do
    field :name, :string
    field :age, :integer
    field :tags, {:array, :string}, default: []
    field :attributes, :map
  end
end
