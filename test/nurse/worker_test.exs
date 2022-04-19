defmodule Nurse.Test.Worker do
  use ExUnit.Case

  require HTTPoison
  require Poison

  @port Application.get_env(:resp_srv, :port)
  @json_header {"Content-Type", "application/json"}

  setup_all do
    Application.start(:resp_srv)

    on_exit(fn ->
      Application.stop(:resp_srv)
    end)
  end

  describe "Nurse.Worker" do
    test "creates healthcheck, validates adaptation to supervised server changing response" do
      resp_srv_configure(202, " ")

      check_delay1 = 500
      retry_delay1 = 1000
      connection_timeout1 = 5000
      evaluation_interval1 = 5

      hc1 =
        Nurse.Healthcheck.from_tuple({
          "hc1",
          :starting,
          {"http", "localhost", @port},
          {:get, [], ""},
          check_delay1,
          retry_delay1,
          connection_timeout1,
          evaluation_interval1,
          {:status_code_match, {:code_equal, 202}},
          5000,
          {:successful_probes_match, {:pos_integer_gte, 3}},
          {:failed_probes_match, {:pos_integer_lte, 3}}
        })

      hc1_id = hc1 |> Nurse.create()

      (check_delay1 * evaluation_interval1 + 500) |> :timer.sleep()

      assert :healthy == (hc1_id |> Nurse.get() |> Kernel.elem(2)).health_status,
             "Status should be healthy"

      resp_srv_configure(400, " ")
      (check_delay1 * evaluation_interval1 + 500) |> :timer.sleep()

      assert :unhealthy == (hc1_id |> Nurse.get() |> Kernel.elem(2)).health_status,
             "Status should be unhealthy"

      (check_delay1 * 2) |> :timer.sleep()
      resp_srv_configure(202, " ")
      (check_delay1 * 3 + retry_delay1) |> :timer.sleep()

      assert :retrying == (hc1_id |> Nurse.get() |> Kernel.elem(2)).health_status,
             "Status should be retrying"
    end
  end

  defp resp_srv_configure(status, body) do
    HTTPoison.post!(
      "localhost:" <> Integer.to_string(@port) <> "/config",
      Poison.encode!(%{"body" => body, "code" => status}),
      [@json_header]
    )
  end
end
