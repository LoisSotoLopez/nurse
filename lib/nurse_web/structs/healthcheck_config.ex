defmodule NurseWeb.HealthcheckConfig do
  alias Nurse

  @type key() :: String.t()

  @type t() :: %{
          check_name: Nurse.name(),
          check_delay: Nurse.check_delay(),
          connection_timeout: Nurse.connection_timeout(),
          evaluation_interval: Nurse.evaluation_interval(),
          request_method: Nurse.method(),
          request_body: Nurse.body(),
          request_header: Nurse.headers(),
          request_hostname: Nurse.hostname(),
          request_port: Nurse.eport(),
          request_scheme: Nurse.scheme(),
          response_timeout: Nurse.response_timeout(),
          retry_delay: Nurse.retry_delay(),
          health_condition: Nurse.health_condition(),
          retry_condition: Nurse.retry_condition(),
          response_condition: Nurse.response_condition()
        }

  @spec keys() :: List.t()
  def keys() do
    [
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
  end

  @spec get(t(), atom()) :: any()
  def get(map, key) do
    Map.get(map, key, nil)
  end

  @spec from_map(Map.t()) :: t() | {:missing_key, key()} | {:repeated_key, key()}
  def from_map(map) do
    fold_fun = fn key, acc ->
      key_str = Atom.to_string(key)
      throw_fun = fn -> throw({:missing_key, key}) end
      new_val = Map.get_lazy(map, key_str, throw_fun)
      add(key_str, new_val, acc)
    end

    try do
      List.foldl(keys(), new(), fold_fun)
    catch
      {error, key} ->
        {error, key}
    end
  end

  @spec new() :: map()
  defp new() do
    %{}
  end

  @spec add(String.t(), any(), t()) :: t()
  defp add(key, value, config) do
    Map.put_new(config, key, value)
  end
end
