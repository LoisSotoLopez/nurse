defmodule RespSrv.MixProject do
  use Mix.Project

  def project do
    [
      app: :resp_srv,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {RespSrv.Application, []},
      env: [port: 8080]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.3.0"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end

  # Aliases
  defp aliases do
    [
      run: ["run --no-halt"]
    ]
  end
end
