defmodule Nurse.Worker do
  alias Nurse.Client
  alias Nurse.Checker
  alias Nurse.Dets
  alias Nurse.Healthcheck

  require Nurse

  @spec start_link(Nurse.healthcheck()) :: no_return()
  def start_link(healthcheck) do
    run(healthcheck)
  end

  @spec run(Nurse.healthcheck()) :: no_return()
  defp run(%Nurse.Healthcheck{health_status: :stoppping} = state),
    do: state |> listen_for_updates() |> run()

  defp run(state) do
    probes =
      state.evaluation_interval
      |> Enum.map(fn _i ->
        task =
          Task.async(fn ->
            Client.request(
              state.endpoint,
              state.request,
              state.connection_timeout,
              state.receive_timeout
            )
          end)

        Process.sleep(state.check_delay)
        task
      end)
      |> Enum.map(fn task -> task |> Task.await() end)
      |> Checker.check_responses(state.response_condition)

    status_candidate =
      probes
      |> Checker.check_health(state.health_condition)

    health_status =
      case status_candidate do
        :unhealthy ->
          case Checker.check_retry(probes, state.retry_condition) do
            :retrying ->
              Process.sleep(state.retry_delay)
              :retrying

            :unhealthy ->
              :unhealthy
          end

        :healthy ->
          :healthy
      end

    new_state =
      state
      |> Healthcheck.update({:health_status, health_status})
      |> listen_for_updates()

    Nurse.table()
    |> Dets.insert(new_state |> Healthcheck.to_tuple())

    new_state
    |> run()
  end

  defp listen_for_updates(state) do
    receive do
      to_update -> state |> Healthcheck.update(to_update) |> listen_for_updates()
    after
      1_000 -> state
    end
  end
end
