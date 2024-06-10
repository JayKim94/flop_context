import Config

config :flop_context, FlopContext.Repo,
  username: "postgres",
  password: "password",
  database: "flop_context_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :flop_context, ecto_repos: [FlopContext.Repo]
