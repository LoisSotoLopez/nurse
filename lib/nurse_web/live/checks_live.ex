defmodule NurseWeb.ChecksLive do
  use NurseWeb, :live_view
  import Phoenix.LiveView.Helpers
  require Logger

  def mount(_params, session, socket) do
    Process.send_after(self(), :update, 1000)
    {:ok, assign(socket, random_num: :rand.uniform(10), refresh_live_time: 1)}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, socket.assigns.refresh_live_time * 1000)
    {:noreply, assign(socket, :random_num, :rand.uniform(10))}
  end

  def handle_event(
        "set_refresh",
        %{"refresh-time" => refresh_live_time, "value" => _value},
        socket
      ) do
    {intval, _} = Integer.parse(refresh_live_time)
    socket = assign(socket, refresh_live_time: intval)
    {:noreply, socket}
  end
end
