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
      dialyzer: dialyzer(),
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
      {:bypass, "~> 2.1", only: :test},
      {:dialyxir, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:elixir_uuid, "~> 1.2"},
      {:floki, ">= 0.30.0", only: :test},
      {:gettext, "~> 0.11"},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.0"},
      {:phoenix, "~> 1.5.12"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_dashboard, "~> 0.4"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.15.1"},
      {:plug_cowboy, "~> 2.0"},
      {:stream_data, "~> 0.5.0", only: :test},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:yaml_elixir, "~> 2.8"}
    ]
  end

  # Aliases
  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"]
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end
end
