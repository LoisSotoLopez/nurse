defmodule RespSrv.Configurator do
  use GenServer

  alias Plugg.Conn

  # Startup callbacks

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: Configurator)
  end

  # API callbacks
  @spec set_resp_code(code :: Conn.status()) :: :ok
  def set_resp_code(code) do
    GenServer.cast(Configurator, {:set_resp_code, code})
  end

  @spec get_resp_code() :: Con.status()
  def get_resp_code() do
    GenServer.call(Configurator, :get_resp_code)
  end

  @spec set_resp_body(body :: Con.body()) :: :ok
  def set_resp_body(body) do
    GenServer.cast(Configurator, {:set_resp_body, body})
  end

  @spec get_resp_body() :: Conn.body()
  def get_resp_body() do
    GenServer.call(Configurator, :get_resp_body)
  end

  @spec set_resp_headers(headers :: Conn.headers()) :: :ok
  def set_resp_headers(headers) do
    GenServer.call(Configurator, {:set_resp_headers, headers})
  end

  @spec get_resp_headers() :: Conn.headers()
  def get_resp_headers() do
    GenServer.call(Configurator, :get_resp_headers)
  end

  # GenServer callback
  @impl true
  def init(_) do
    {:ok,
     %{
       "code" => 200,
       "body" => "HelloWorld!",
       "headers" => []
     }}
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
  def handle_cast({:set_resp_headers, headers}, st) do
    {:noreply, Map.put(st, "headers", headers)}
  end

  @impl true
  def handle_call(:get_resp_code, _from, %{"code" => code} = st) do
    {:reply, code, st}
  end

  @impl true
  def handle_call(:get_resp_body, _from, %{"body" => body} = st) do
    {:reply, body, st}
  end

  @impl true
  def handle_call(:get_resp_headers, _from, %{"headers" => headers} = st) do
    {:reply, headers, st}
  end
end
