defmodule FlopContext.Repo.Migrations.CreateTestTables do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :age, :integer
      add :active, :boolean, default: true

      timestamps()
    end

    create table(:posts) do
      add :title, :string
      add :content, :string
      add :published, :boolean, default: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create table(:comments) do
      add :content, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :nothing)

      timestamps()
    end
  end
end
