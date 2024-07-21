defmodule FlopContext.MixProject do
  use Mix.Project

  def project do
    [
      app: :flop_context,
      version: "0.1.0",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "FlopContext",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:flop, "~> 0.25.0"},
      {:ecto, "~> 3.10"},
      {:ecto_sql, "~> 3.11.0", only: :test},
      {:ex_machina, "~> 2.4", only: :test},
      {:postgrex, ">= 0.0.0", only: :test},
      {:stream_data, "~> 1.0", only: :test}
    ]
  end

  defp aliases do
    [
      "ecto.reset": ["ecto.drop", "ecto.create --quiet", "ecto.migrate"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
