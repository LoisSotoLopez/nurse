defmodule Nurse.MixProject do
  use Mix.Project

  def project do
    [
      app: :nurse,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  def application do
    [
      mod: {Nurse.Application, []},
      extra_applications: [:logger, :runtime_tools, :ex_unit]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Project dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.6"},
      {:floki, ">= 0.30.0", only: :test},
      {:gettext, "~> 0.11"},
      {:httpoison, "~> 1.7"},
      {:jason, "~> 1.0"},
      {:phoenix, "~> 1.5.12"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_dashboard, "~> 0.4"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.15.1"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"}
    ]
  end

  # Aliases
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
