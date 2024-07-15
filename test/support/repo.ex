defmodule FlopContext.Repo do
  use Ecto.Repo,
    otp_app: :flop_context,
    adapter: Ecto.Adapters.Postgres
end
