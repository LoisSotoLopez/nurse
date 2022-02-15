defmodule RespSrv.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  match _ do
    code = 200
    body = "HelloWorld!"
    send_resp(conn, code, body)
  end
end
