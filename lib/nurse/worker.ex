defmodule Nurse.Worker do
  alias Nurse.Client
  alias Nurse.Checker
  alias Nurse.Dets
  alias Nurse.Healthcheck

  require Nurse
  require Logger

  @spec start_link(Nurse.uuid()) :: no_return()
  def start_link(id) do
    Logger.info("[worker(#{inspect(id)})] Starting.")
    id |> read_state() |> run(id)
  end

  @spec run(Nurse.healthcheck(), Nurse.uuid()) :: no_return()
  defp run(state, id) do
    Logger.info("[worker(#{inspect(id)})] Running ...")

    probes =
      1..state.evaluation_interval
      |> Enum.map(fn _i ->
        Process.sleep(state.check_delay)

        Task.async(fn ->
          Client.request(
            state.endpoint,
            state.request,
            state.connection_timeout,
            state.response_timeout
          )
        end)
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
      read_state(id)
      |> Healthcheck.update({:health_status, health_status})

    Nurse.table()
    |> Dets.insert({id, self(), new_state})

    new_state
    |> run(id)
  end

  defp read_state(id) do
    {_id, _pid, hc} =
      Nurse.table()
      |> Dets.lookup(id)

    hc
  end
end
