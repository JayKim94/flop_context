defmodule FlopContext.Schemas.User do
  use Ecto.Schema

  import Ecto.Changeset

  @flop_fields [:name, :email, :age, :active]

  @derive {
    Flop.Schema,
    filterable: @flop_fields,
    sortable: @flop_fields,
    default_pagination_type: :page
  }

  schema "users" do
    field :name, :string
    field :email, :string
    field :age, :integer
    field :active, :boolean, default: true

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :age, :active])
    |> validate_required([:name, :email])
    |> unique_constraint(:email)
  end
end
