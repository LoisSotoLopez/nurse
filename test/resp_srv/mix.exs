defmodule RespSrv.MixProject do
  use Mix.Project

  def project do
    [
      app: :resp_srv,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {RespSrv.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.3.0"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
