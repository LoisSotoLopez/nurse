defmodule RespSrv.Router do
  use Plug.Router

  alias Plug.Conn
  alias RespSrv.Configurator

  plug :match

  plug Plug.Parsers,
    parsers: [:urlencoded, :json],
    json_decoder: Jason

  plug :dispatch

  post "/config" do
    body = Map.get(conn.body_params, "body")
    code = Map.get(conn.body_params, "code")
    Configurator.set_resp_body(body)
    Configurator.set_resp_code(code)
    send_resp(conn, 200, [])
  end

  match _ do
    req_method = conn.method
    req_url = Conn.request_url(conn)

    code = Configurator.get_resp_code()
    body = Configurator.get_resp_body()
    headers = Configurator.get_resp_headers()

    IO.puts("Received " <> req_method <> " on " <> req_url)

    put_resp_headers(conn, headers)
    |> send_resp(code, body)
  end

  @spec put_resp_headers(conn :: Conn.t(), list :: Conn.headers()) :: Conn.t()
  defp put_resp_headers(conn, []) do
    conn
  end

  defp put_resp_headers(conn, [{header_key, header_val} | rest]) do
    Conn.put_resp_header(conn, header_key, header_val)
    |> put_resp_headers(rest)
  end
end
