defmodule NurseWeb.HealthcheckConfig do
  alias Nurse
  alias NurseWeb.HealthcheckConfig

  defstruct [
    :check_name,
    :check_delay,
    :connection_timeout,
    :evaluation_interval,
    :request_method,
    :request_body,
    :request_header,
    :request_hostname,
    :request_port,
    :request_scheme,
    :response_timeout,
    :retry_delay,
    :health_condition,
    :retry_condition,
    :response_condition
  ]

  @type t() :: %NurseWeb.HealthcheckConfig{}

  @type key() :: String.t()

  @spec get(t(), atom()) :: any()
  def get(map, key) do
    Map.get(map, key, nil)
  end

  @spec from_map(Map.t()) :: t() | {:missing_key, key()}
  def from_map(map) do
    fold_fun = fn key, acc ->
      key_str = Atom.to_string(key)
      throw_fun = fn -> throw({:missing_key, key_str}) end
      new_val = Map.get_lazy(map, key_str, throw_fun)
      Map.put(acc, key_str, new_val)
    end

    try do
      HealthcheckConfig.__struct__()
      |> Map.keys()
      |> tail()
      |> List.foldl(new(), fold_fun)
    catch
      {error, key} ->
        {error, key}
    end
  end

  @spec new() :: map()
  defp new() do
    %HealthcheckConfig{}
  end

  defp tail([_h, t]) do
    t
  end
end
