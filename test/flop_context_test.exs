defmodule FlopContextTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import FlopContext.Factory

  alias Ecto.Adapters.SQL.Sandbox
  alias FlopContext.Repo

  alias FlopContext.Contexts.Users

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  describe "get_user/1" do
    test "returns a user" do
      users = insert_list(20, :user)
      expected = Enum.sort(users, &(&1.id < &2.id))

      assert Users.list_users() == expected
    end
  end
end
