defmodule Nurse.Checker do
  alias Nurse.Condition

  @spec check_responses([{:ok, Nurse.response()} | {:error, any()}], Nurse.response_condition()) ::
          Nurse.probes_results()
  def check_responses(responses, response_condition) do
    responses
    |> Enum.reduce({0, 0}, fn {result, response}, {successful, failed} ->
      case result do
        :ok ->
          case Condition.Response.check(response, response_condition) do
            true -> {successful + 1, failed}
            _false -> {successful, failed + 1}
          end

        :error ->
          {successful, failed + 1}
      end
    end)
  end

  @spec check_health(Nurse.probes_results(), Nurse.health_condition()) :: :healthy | :unhealthy
  def check_health(probes, health_condition) do
    case Condition.Health.check(probes, health_condition) do
      true -> :healthy
      _false -> :unhealthy
    end
  end

  @spec check_retry(Nurse.probes_results(), Nurse.retry_condition()) :: :retrying | :unhealthy
  def check_retry(probes, retry_condition) do
    case Condition.Retry.check(probes, retry_condition) do
      true -> :retrying
      _false -> :unhealthy
    end
  end
end
