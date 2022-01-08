defmodule NurseWeb.HealthcheckSummary do
  defstruct [
    :id,
    :name,
    :health_status,
    :scheme,
    :hostname,
    :eport,
    :method,
    :evaluation_interval
  ]

  @type t :: %NurseWeb.HealthcheckSummary{}

  def new(), do: %NurseWeb.HealthcheckSummary{} 

  @spec from_tuple(
    {
      Nurse.id(),
      Nurse.name(),
      Nurse.health_status(),
      Nurse.scheme(),
      Nurse.hostname(),
      Nurse.eport(),
      Nurse.method(),
      Nurse.evaluation_interval()
    }) :: HealthcheckSummary.t()
  def from_tuple({
      id,
      name,
      health_status,
      scheme,
      hostname,
      eport,
      method,
      evaluation_interval
  }),
  do: %NurseWeb.HealthcheckSummary{
      id: id,
      name: name,
      health_status: health_status,
      scheme: scheme,
      hostname: hostname,
      eport: eport,
      method: method,
      evaluation_interval: evaluation_interval
  }
end