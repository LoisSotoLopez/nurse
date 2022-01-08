defmodule Nurse.Healthcheck do
  defstruct [
    :name,
    :health_status,
    :endpoint,
    :request,
    :check_delay,
    :retry_delay,
    :evaluation_interval,
    :response_condition,
    :health_condition,
    :retry_condition
  ]

  @type t :: %Nurse.Healthcheck{}

  def new(), do: %Nurse.Healthcheck{}

  def from_tuple(
        {name, health_status, endpoint, request, check_delay, retry_delay, evaluation_interval,
         response_condition, health_condition, retry_condition}
      ),
      do: %Nurse.Healthcheck{
        name: name,
        health_status: health_status,
        endpoint: endpoint,
        request: request,
        check_delay: check_delay,
        retry_delay: retry_delay,
        evaluation_interval: evaluation_interval,
        response_condition: response_condition,
        health_condition: health_condition,
        retry_condition: retry_condition
      }

  def to_tuple(%Nurse.Healthcheck{
        name: name,
        health_status: health_status,
        endpoint: endpoint,
        request: request,
        check_delay: check_delay,
        retry_delay: retry_delay,
        evaluation_interval: evaluation_interval,
        response_condition: response_condition,
        health_condition: health_condition,
        retry_condition: retry_condition
      }),
      do:
        {name, health_status, endpoint, request, check_delay, retry_delay, evaluation_interval,
         response_condition, health_condition, retry_condition}

  def update(healthcheck, {key, value}), do: Map.put(healthcheck, key, value)
end
