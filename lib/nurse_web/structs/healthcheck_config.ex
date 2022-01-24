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
    [:check_name,
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
    :response_condition]
  end

  @spec new() :: t()
  def new() do
    %{}
  end

  @spec get(atom(), t()) :: any()
  def get(key, map) do
    Map.get(map, key)
  end

  @spec add(String.t(), any(), t()) :: t()
  defp add(key, value, config) do
    case Map.has_key?(config, key) do
      true ->
        throw({:repeated_key, key})
      _ ->
        Map.put_new(config, key, value)
    end
  end

  @spec from_map( Map.t() ) :: t() | {:missing_key, key()} | {:repeated_key, key()}
  def from_map( map ) do
    fold_fun =
      fn ( key , acc) ->
        throw_fun = fn -> throw({:missing_key, key}) end
        new_val = Map.get_lazy(map, Atom.to_string(key), throw_fun)
        throw_if_not(new_val, key)
        add(key, new_val, acc)
      end
    try do
      List.foldl(keys(), new(), fold_fun)
    catch
      {error, key} ->
        {error, key}
    end
  end


  defp throw_if_not(value, key) do
    try do
      IO.puts "trying " <> value <> " of key " <> Atom.to_string(key) <> "\n"
      is_type(key, value)
    catch
      _ ->
        IO.puts "exception\n"
        throw({:bad_type, key, value})
    end
  end

  # Type validation functions

  @spec is_type(:check_name, Nurse.name()) :: :true
  @spec is_type(:check_delay,  Nurse.check_delay()) :: :true
  @spec is_type(:connection_timeout,  Nurse.connection_timeout()) :: :true
  @spec is_type(:evaluation_interval,  Nurse.evaluation_interval()) :: :true
  @spec is_type(:request_method,  Nurse.method()) :: :true
  @spec is_type(:request_body,  Nurse.body()) :: :true
  @spec is_type(:request_header,  Nurse.headers()) :: :true
  @spec is_type(:request_hostname,  Nurse.hostname()) :: :true
  @spec is_type(:request_port,  Nurse.eport()) :: :true
  @spec is_type(:request_scheme,  Nurse.scheme()) :: :true
  @spec is_type(:response_timeout,  Nurse.response_timeout()) :: :true
  @spec is_type(:retry_delay,  Nurse.retry_delay()) :: :true
  @spec is_type(:health_condition,  Nurse.health_condition()) :: :true
  @spec is_type(:retry_condition,  Nurse.retry_condition()) :: :true
  @spec is_type(:response_condition,  Nurse.response_condition()) :: :true
  defp is_type(_type, _value) do
    :true
  end
end
