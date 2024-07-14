defmodule FlopContext.MixProject do
  use Mix.Project

  def project do
    [
      app: :flop_context,
      version: "0.1.0",
      elixir: "~> 1.16",
      name: "FlopContext",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

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
      {:postgrex, ">= 0.0.0", only: :test}
    ]
  end
end
