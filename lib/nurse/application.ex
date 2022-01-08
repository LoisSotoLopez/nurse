defmodule Nurse.Application do
  @moduledoc false
  use Application

  require Nurse

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      NurseWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Nurse.PubSub},
      # Start the Endpoint (http/https)
      NurseWeb.Endpoint,
      # Start the Leader
      {Nurse.Leader, Nurse.table()}
    ]

    opts = [strategy: :one_for_one, name: Nurse.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NurseWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
