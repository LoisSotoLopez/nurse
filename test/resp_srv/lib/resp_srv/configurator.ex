defmodule RespSrv.Configurator do
  use GenServer

  # Startup callbacks

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: Configurator)
  end

  # API callbacks
  def set_resp_code(code) do
    GenServer.cast(Configurator, {:set_resp_code, code})
  end

  def get_resp_code() do
    GenServer.call(Configurator, :get_resp_code)
  end

  def set_resp_body(body) do
    GenServer.cast(Configurator, {:set_resp_body, body})
  end

  def get_resp_body() do
    GenServer.call(Configurator, :get_resp_body)
  end

  # GenServer callback
  @impl true
  def init(_) do
    {:ok, %{"code" => 200, "body" => "HelloWorld!"}}
  end
  @impl true
  def handle_cast({:set_resp_code, code}, st) do
    {:noreply, Map.put(st, "code", code)}
  end
  @impl true
  def handle_cast({:set_resp_body, body}, st) do
    {:noreply, Map.put(st, "body", body)}
  end

  @impl true
  def handle_call(:get_resp_code, _from, %{"code" => code} = st) do
    {:reply, code, st}
  end
  @impl true
  def handle_call(:get_resp_body, _from, %{"body" => body} = st) do
    {:reply, body, st}
  end

end
