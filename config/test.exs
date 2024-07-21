import Config

config :flop_context,
  ecto_repos: [FlopContext.Repo],
  repo: FlopContext.Repo

config :flop_context, FlopContext.Repo,
  username: "postgres",
  password: "password",
  database: "flop_context_dev",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :stream_data,
  max_runs: if(System.get_env("CI"), do: 100, else: 50),
  max_run_time: if(System.get_env("CI"), do: 3000, else: 200)
