defmodule RespSrv.Application do
  use Application
  require Logger

  def start(_type, _args) do
    port = Application.get_env(:resp_srv, :port)
    children = [
      {RespSrv.Configurator, []},
      {Plug.Cowboy, scheme: :http, plug: RespSrv.Router, options: [port: port]}
    ]

    opts = [strategy: :one_for_one, name: RespSrv.Supervisor]

    Logger.info("Starting application")

    Supervisor.start_link(children, opts)
  end
end
