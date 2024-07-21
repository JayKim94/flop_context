{:ok, _pid} = FlopContext.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(FlopContext.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start()
