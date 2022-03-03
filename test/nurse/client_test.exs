defmodule Nurse.Test.Client do
  use ExUnit.Case, async: true

  @scheme "http"
  @hostname "localhost"
  @port 8081

  setup do
    bypass = Bypass.open(port: @port)
    {:ok, bypass: bypass}
  end

  describe "Nurse.Client" do
    test "sends and receives correctly a GET request", %{bypass: bypass} do
      {:ok, body} = Jason.encode(%{"foo" => "bar"})

      Bypass.expect(bypass, "GET", "", fn conn ->
        Plug.Conn.resp(conn, 200, body)
      end)

      endpoint = {@scheme, @hostname, @port}
      request = {:get, [], ""}
      {:ok, {200, _headers, "{\"foo\":\"bar\"}"}} = Nurse.Client.request(endpoint, request)
    end
  end
end
