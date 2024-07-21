defmodule FlopContext.Schemas.Comment do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias FlopContext.Schemas.Post
  alias FlopContext.Schemas.User

  schema "comments" do
    field :content, :string
    belongs_to :user, User
    belongs_to :post, Post

    timestamps()
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :user_id, :post_id])
    |> validate_required([:content, :user_id, :post_id])
  end
end
