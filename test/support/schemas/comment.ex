defmodule FlopContext.Schemas.Comment do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias FlopContext.Schemas.Post
  alias FlopContext.Schemas.User

  schema "comments" do
    field :content, :string
    belongs_to :user, MyApp.Accounts.User
    belongs_to :post, MyApp.Blog.Post

    timestamps()
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :user_id, :post_id])
    |> validate_required([:content, :user_id, :post_id])
  end
end
