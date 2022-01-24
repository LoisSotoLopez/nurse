defmodule NurseWeb.NewCheckLive do
  use NurseWeb, :live_view

  alias Nurse.Healthcheck
  alias NurseWeb.Client
  alias NurseWeb.ConfigProcessor
  alias NurseWeb.HealthcheckConfig, as: HC

  require Logger

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        yaml_conf: "",
        bad_input_msg: "")
    {:ok, socket}
  end

  def handle_event(
        "submit_check_configuration",
        params,
        socket
      ) do
    yaml_conf = Map.get(params, "yaml_conf")
    case ConfigProcessor.process(yaml_conf) do
      {:ok, config} ->
        {HC.get(config, "check_name"),
          :starting,
          {
            HC.get(config,"request_scheme"),
            HC.get(config,"request_hostname"),
            HC.get(config,"request_port")
          },
          {
            HC.get(config,"request_method"),
            HC.get(config,"request_header"),
            HC.get(config,"request_body")
          },
          HC.get(config,"check_delay"),
          HC.get(config,"retry_delay"),
          HC.get(config,"connection_timeout"),
          HC.get(config,"evaluation_interval"),
          HC.get(config,"response_condition"),
          HC.get(config,"response_timeout"),
          HC.get(config,"health_condition"),
          HC.get(config,"retry_condition")}
        |>Healthcheck.from_tuple()
        |>Client.create
        {:noreply, redirect(socket, to: "/all-checks")}
      {:error, error_string} ->
        socket =
          assign(socket,
            bad_input_msg:
              error_string
          )
          |> assign(yaml_conf: yaml_conf)

        {:noreply, socket}
    end
  end

end
