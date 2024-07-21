defmodule FlopContext.Schemas.Post do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias FlopContext.Schemas.User

  schema "posts" do
    field :title, :string
    field :content, :string
    field :published, :boolean, default: false
    belongs_to :user, User

    timestamps()
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :published, :user_id])
    |> validate_required([:title, :content, :user_id])
  end
end
