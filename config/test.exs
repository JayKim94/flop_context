import Config

config :flop_context,
  repo: FlopContext.Repo,
  username: "postgres",
  password: "password",
  database: "flop_context_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
