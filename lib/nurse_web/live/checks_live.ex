defmodule NurseWeb.ChecksLive do
  use NurseWeb, :live_view

  import Phoenix.LiveView.Helpers

  require Logger

  alias Elixir.List

  alias Nurse.Dets
  alias Nurse.Healthcheck
  alias NurseWeb.HealthcheckSummary
  alias NurseWeb.Client

  ### ------------------------
  ### LIVE VIEW MOUNT
  ### ------------------------

  def mount(_params, session, socket) do
    Process.send_after(self(), :update, 5000)

    socket =
      assign(
        socket,
        checks_list: obtain_checks_summary_list()
      )
      |> assign(pannel_refresh_time: 5)

    {:ok, socket}
  end

  ### ------------------------
  ### HANDLE FUNCTIONS
  ### ------------------------

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, socket.assigns.pannel_refresh_time * 1000)

    socket = assign(socket, checks_list: obtain_checks_summary_list())

    {:noreply, socket}
  end

  def handle_event(
        "set_refresh",
        %{"refresh-time" => pannel_refresh_time, "value" => _value},
        socket
      ) do
    {intval, _} = Integer.parse(pannel_refresh_time)
    socket = assign(socket, pannel_refresh_time: intval)
    {:noreply, socket}
  end

  def handle_event(
        "switch_check",
        %{"switch-ref" => _to_switch_check_reference, "value" => _value},
        socket
      ) do
    {:noreply, socket}
  end

  def handle_event(
        "remove_check",
        %{"check-ref" => check_ref},
        socket
      ) do
  end

  ### ------------------------
  ### INTERNAL FUNCTIONS
  ### ------------------------

  # @spec obtain_check( Nurse.uuid() ) :: HealthcheckSummary.t()
  # defp obtain_check_summary( id ) do
  #   Client.get( id )
  #   |> hc_to_hcsummary
  # end

  @spec remove_check(Nurse.uuid()) :: :ok
  defp remove_check(id) do
    Client.remove(id)
  end

  @spec obtain_checks_summary_list() :: list(HealthcheckSummary.t())
  defp obtain_checks_summary_list() do
    Client.get_all()
    |> Enum.map(fn table_row -> hc_to_hcsummary(table_row) end)
    |> Enum.sort(fn x, y ->
      x.name < y.name
    end)
  end

  @spec hc_to_hcsummary({Nurse.uuid(), pid(), Nurse.Healthcheck.t()}) :: HealthcheckSummary.t()
  defp hc_to_hcsummary({
         id,
         _pid,
         %Healthcheck{
           name: name,
           health_status: health_status,
           endpoint: {scheme, hostname, eport},
           request: {method, _headers, _body},
           evaluation_interval: evaluation_interval
         }
       }) do
    HealthcheckSummary.from_tuple({
      id,
      name,
      health_status,
      scheme,
      hostname,
      eport,
      method,
      evaluation_interval
    })
  end
end
