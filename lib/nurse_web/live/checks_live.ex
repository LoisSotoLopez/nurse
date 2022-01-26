defmodule NurseWeb.ChecksLive do
  use NurseWeb, :live_view
  import Phoenix.LiveView.Helpers
  require Logger

  def mount(_params, _session, socket) do
    Process.send_after(self(), :update, 5000)

    socket =
      assign(socket, random_num: :rand.uniform(10))
      |> assign(pannel_refresh_time: 5)
      |> assign(
        checks_list: [%{:check_reference => "001", :status => "on", :switch_action => "off"}]
      )

    {:ok, socket}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, socket.assigns.pannel_refresh_time * 1000)
    {:noreply, assign(socket, random_num: :rand.uniform(10))}
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
end
