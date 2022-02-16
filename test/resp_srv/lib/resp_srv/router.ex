defmodule RespSrv.Router do
  use Plug.Router

  alias RespSrv.Configurator

  plug :match
  plug Plug.Parsers,
    parsers: [:urlencoded, :json],
    json_decoder: Jason
  plug :dispatch


  post "/config" do
    {:ok, _, conn1} = Plug.Conn.read_body(conn, opts)
    body = Map.get(conn1.body_params, "body")
    code = Map.get(conn1.body_params, "code")
    Configurator.set_resp_body(body)
    Configurator.set_resp_code(code)
    send_resp(conn, 200, [])
  end

  match _ do
    code = Configurator.get_resp_code()
    body = Configurator.get_resp_body()
    send_resp(conn, code, body)
  end
end
