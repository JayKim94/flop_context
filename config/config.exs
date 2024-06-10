import Config

config :flop_context, FlopContext.Repo,
  username: "postgres",
  password: "password",
  database: "flop_context_dev",
  hostname: "localhost"

config :flop_context, ecto_repos: [FlopContext.Repo]
