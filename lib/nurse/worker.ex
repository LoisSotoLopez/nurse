defmodule Nurse.Worker do
  alias Nurse.Client
  alias Nurse.Checker
  alias Nurse.Dets
  alias Nurse.Healthcheck
  alias Nurse.Nurselog

  require Nurse

  @spec start_link(Nurse.uuid()) :: no_return()
  def start_link(id) do
    Nurselog.info_w("[worker(#{inspect(id)})] Starting.")
    id |> run
  end

  @spec run(Nurse.uuid()) :: no_return()
  defp run(id) do
    Nurselog.info_w("[worker(#{inspect(id)})] Running ...")

    state =
      id
      |> read_state

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

    Nurselog.info_w("[worker(#{inspect(id)})] Probes are #{inspect(probes)}.")

    status_candidate =
      probes
      |> Checker.check_health(state.health_condition)

    Nurselog.info_w("[worker(#{inspect(id)})] Status candidate is #{inspect(status_candidate)}.")

    health_status =
      case status_candidate do
        :unhealthy ->
          Nurselog.info_w("[worker(#{inspect(id)})] Therefore doing retry.")

          case Checker.check_retry(probes, state.retry_condition) do
            :retrying ->
              Nurselog.info_w("[worker(#{inspect(id)})] Already retrying. Sleeping now ...")
              Process.sleep(state.retry_delay)
              :retrying

            :unhealthy ->
              Nurselog.info_w("[worker(#{inspect(id)})] Health status is :unhealthy after retry.")
              :unhealthy
          end

        :healthy ->
          :healthy
      end

    Nurselog.info_w("[worker(#{inspect(id)})] New health status is #{inspect(health_status)}.")

    new_state =
      id
      |> read_state
      |> Healthcheck.update({:health_status, health_status})

    Nurse.table()
    |> Dets.insert({id, self(), new_state})

    id
    |> run
  end

  defp read_state(id) do
    {_id, _pid, hc} =
      Nurse.table()
      |> Dets.lookup(id)

    hc
  end
end
