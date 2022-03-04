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

  @type t :: %NurseWeb.HealthcheckConfig{}

  @type key() :: String.t()

  @spec get(t(), atom()) :: any()
  def get(map, key) do
    Map.get(map, key, nil)
  end

  @spec from_map(map :: map()) :: t() | {:error, tuple()}
  def from_map(map) do
    fold_fun = fn key, acc ->
      key_str = Atom.to_string(key)
      throw_fun = fn -> throw({:missing_key, key_str}) end
      new_val = Map.get_lazy(map, key_str, throw_fun)
      conf_val = to_config(key, new_val)
      Map.put(acc, key, conf_val)
    end

    try do
      HealthcheckConfig.__struct__()
      |> Map.keys()
      |> tail()
      |> List.foldl(new(), fold_fun)
    catch
      error ->
        {:error, error}
    end
  end

  @spec new() :: t()
  defp new() do
    %HealthcheckConfig{}
  end

  defp tail([_h | t]) do
    t
  end

  defp to_config(atom, val)
       when (atom == :check_name or
               atom == :request_body or
               atom == :request_hostname) and
              is_bitstring(val) do
    val
  end

  defp to_config(atom, val)
       when (atom == :check_delay or
               atom == :connection_timeout or
               atom == :evaluation_interval or
               atom == :response_timeout or
               atom == :retry_delay or
               atom == :request_port) and
              is_integer(val) and val > 0 do
    val
  end

  defp to_config(:request_header, val)
       when is_bitstring(val) do
    header_fun = fn str ->
      String.split(str, ":", [])
      |> List.to_tuple()
    end

    String.replace(val, "\n", "")
    |> String.replace("{", "")
    |> String.replace("}", "")
    |> String.replace(" ", "")
    |> String.split(",", [])
    |> Enum.map(header_fun)
  end

  defp to_config(:request_method, val)
       when val == "GET" or
              val == "PUT" or
              val == "POST" or
              val == "PATCH" do
    val
  end

  defp to_config(:request_scheme, val)
       when val == "http" or
              val == "https" do
    val
  end

  defp to_config(:health_condition, val) when is_map(val) do
    case val do
      %{"successful_probes_match" => succ_pm} ->
        {:successful_probes_match, to_config(:pos_integer_match, succ_pm)}

      %{"failed_probes_match" => fail_pm} ->
        {:failed_probes_match, to_config(:pos_integer_match, fail_pm)}

      %{"type" => "not", "health_condition" => condition} ->
        {:not, to_config(:health_condition, condition)}

      %{
        "type" => binary_type,
        "health_condition_1" => condition1,
        "health_condition_2" => condition2
      } ->
        {
          to_config(binary_type),
          to_config(:health_condition, condition1),
          to_config(:health_condition, condition2)
        }

      _ ->
        throw({:bad_input, val})
    end
  end

  defp to_config(:retry_condition, val) when is_map(val) do
    to_config(:health_condition, val)
  end

  defp to_config(:response_condition, val) when is_map(val) do
    case val do
      %{"status_code_match" => match} when is_map(match) ->
        {:status_code_match, to_config(:status_code_match, match)}

      %{"headers_match" => proplist_match} when is_map(proplist_match) ->
        {:headers_match, to_config(:proplist_match, proplist_match)}

      %{"body_match" => match} when is_map(match) ->
        {:body_match, to_config(:body_match, match)}

      %{"type" => "not", "response_condition" => condition} ->
        {:not, to_config(:response_condition, condition)}

      %{
        "type" => binary_type,
        "response_condition_1" => condition1,
        "response_condition_2" => condition2
      } ->
        {
          to_config(binary_type),
          to_config(:response_condition, condition1),
          to_config(:response_condition, condition2)
        }

      _ ->
        throw({:bad_input, val})
    end
  end

  defp to_config(:status_code_match, match) when is_map(match) do
    case match do
      %{"code_equal" => status_code} ->
        {:code_equal, to_config(:status_code, status_code)}

      %{"code_range" => %{"from" => status_code1, "to" => status_code2}} ->
        {:code_range, to_config(:status_code, status_code1),
         to_config(:status_code, status_code2)}

      %{"code_class" => code_class} ->
        {:code_class, to_config(:code_class, code_class)}

      %{"code_regex" => regex} ->
        {:code_regex, to_config(:code_regex, regex)}

      _ ->
        throw({:bad_input, match})
    end
  end

  defp to_config(:status_code, status_code) when is_integer(status_code) do
    case status_code do
      n when 100 <= status_code and status_code <= 599 ->
        n

      _ ->
        throw({:bad_input, status_code})
    end
  end

  defp to_config(:code_class, code_class) when is_integer(code_class) do
    case code_class do
      n when 1 <= n and n <= 5 ->
        n

      _ ->
        throw({:bad_input, code_class})
    end
  end

  defp to_config(:code_regex, regex) do
    regex
  end

  defp to_config(:proplist_match, proplist_match) when is_map(proplist_match) do
    case proplist_match do
      %{"proplist_has_key" => key} ->
        {:proplist_has_key, key}

      %{"proplist_contains" => %{"key" => contains_key, "value" => contains_value}} ->
        {:proplist_contains, {contains_key, contains_value}}

      _ ->
        throw({:bad_input, proplist_match})
    end
  end

  defp to_config(:body_match, string_match) when is_map(string_match) do
    case string_match do
      %{:string_exact => string_exact} ->
        {:string_exact, string_exact}

      %{:string_iexact => string_iexact} ->
        {:string_iexact, string_iexact}

      %{:string_contains => string_contains} ->
        {:string_contains, string_contains}

      %{:string_icontains => string_icontains} ->
        {:string_icontains, string_icontains}

      %{:string_starts_with => string_starts_with} ->
        {:string_starts_with, string_starts_with}

      %{:string_istarts_with => string_istarts_with} ->
        {:string_istarts_with, string_istarts_with}

      %{:string_ends_with => string_ends_with} ->
        {:string_ends_with, string_ends_with}

      %{:string_iends_with => string_iends_with} ->
        {:string_iends_with, string_iends_with}

      %{:string_regex => string_regex} ->
        {:string_regex, string_regex}

      _ ->
        throw({:bad_input, string_match})
    end
  end

  defp to_config(:pos_integer_match, match) when is_map(match) do
    case match do
      %{"pos_integer_equal" => pos_int_eq} when is_integer(pos_int_eq) ->
        {:pos_integer_equal, pos_int_eq}

      %{"pos_integer_gt" => pos_int_gt} when is_integer(pos_int_gt) ->
        {:pos_integer_gt, pos_int_gt}

      %{"pos_integer_gte" => pos_int_gte} when is_integer(pos_int_gte) ->
        {:pos_integer_gte, pos_int_gte}

      %{"pos_integer_lt" => pos_int_lt} when is_integer(pos_int_lt) ->
        {:pos_integer_lt, pos_int_lt}

      %{"pos_integer_lte" => pos_int_lte} when is_integer(pos_int_lte) ->
        {:pos_integer_lte, pos_int_lte}

      %{"pos_integer_range" => %{"from" => from_integer, "to" => to_integer}}
      when is_integer(from_integer) and is_integer(to_integer) ->
        {:pos_integer_range, from_integer, to_integer}
    end
  end

  defp to_config(key, val) do
    throw({:bad_config, key, val})
  end

  defp to_config("and") do
    :and
  end

  defp to_config("or") do
    :or
  end
end
