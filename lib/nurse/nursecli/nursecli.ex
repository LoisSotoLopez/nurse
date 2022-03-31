defmodule Nurse.NurseCLI do
  require Nurse
  alias Nurse.Healthcheck
  alias Nurse.NurseCLIStatics

  ### ------------------------
  ### EXTERNAL FUNCTIONS
  ### ------------------------
  def get_healthcheck() do
    IO.puts("\nRetrieving healtcheck...")

    id =
      IO.gets("Healthcheck id? ")
      |> String.trim()

    [Nurse.get(id)]
    |> print_hc_rows()
  end

  def get_healthchecks() do
    IO.puts("\nRetrieving all healthchecks...")

    Nurse.get_all()
    |> print_hc_rows()
  end

  @spec create_healthcheck :: :ok | Nurse.Healthcheck.t()
  def create_healthcheck() do
    IO.puts("\nCreating a new healthcheck...")

    try do
      hc =
        Map.keys(Nurse.Healthcheck.__struct__())
        |> tail
        |> gets_healthcheck

      IO.inspect(hc)

      Nurse.create(hc)
    catch
      :stop_creation ->
        IO.puts("\nHealthcheck definition stopped by user")

      _ ->
        IO.puts("\nHealthcheck definition failed")
    end
  end

  ### ------------------------
  ### INTERNAL FUNCTIONS
  ### ------------------------
  defp ask_for(str) do
    str
    |> IO.gets()
    |> String.trim()
  end

  defp check_quit("q") do
    throw(:stop_creation)
  end

  defp check_quit(str) do
    str
  end

  defp convert_pos_integer(str, key) do
    try do
      val =
        str
        |> Integer.parse()

      case val do
        :error ->
          throw({:bad_value, key, str})

        {parsed, _} ->
          case parsed |> Kernel.>(0) do
            true -> parsed
            _ -> throw({:bad_value, key, str})
          end
      end
    catch
      _ -> throw({:bad_value, key, str})
    end
  end

  defp convert_method(str, key) do
    val =
      str
      |> String.to_atom()

    case [:get, :post, :put, :patch, :delete, :options, :head] |> Enum.member?(val) do
      true -> val
      _ -> throw({:bad_value, key, str})
    end
  end

  defp convert_headers(str, _key) do
    map_fun = fn header ->
      [key, value] = header |> String.split(":")
      {key, value}
    end

    case str do
      "" ->
        []

      _ ->
        try do
          str
          |> String.trim()
          |> String.split("|")
          |> Enum.map(map_fun)
        rescue
          _ ->
            throw({:bad_format, :headers, str})
        end
    end
  end

  defp convert_health_condition(str, _key) do
    try do
      str
      |> String.trim()
      |> String.split()
      |> gen_health_cond_part
    rescue
      _ ->
        throw({:bad_format, :response_condition, str})
    end
  end

  defp convert_retry_condition(str, _key) do
    try do
      str
      |> String.trim()
      |> String.split()
      |> gen_health_cond_part
    rescue
      _ ->
        throw({:bad_format, :retry_condition, str})
    end
  end

  defp convert_response_condition(str, _key) do
    try do
      str
      |> String.trim()
      |> String.split()
      |> gen_resp_cond_part
    rescue
      _ ->
        throw({:bad_format, :response_condition, str})
    end
  end

  defp default(:undefined, default) do
    IO.puts("No value provided. Using default #{default}")
    default
  end

  defp default(str, _default) do
    str
  end

  defp gen_resp_cond_part(["not" | t]) do
    {:not, gen_resp_cond_part(t)}
  end

  defp gen_resp_cond_part(["and" | t]) do
    {cond1, cond2} = gen_resp_aggregation_cond(t)
    {:and, cond1, cond2}
  end

  defp gen_resp_cond_part(["or" | t]) do
    {cond1, cond2} = gen_resp_aggregation_cond(t)
    {:or, cond1, cond2}
  end

  defp gen_resp_cond_part(["status" | t]) do
    {:status_code_match, gen_resp_code_match(t)}
  end

  defp gen_resp_cond_part(["headers" | t]) do
    {:headers_match, gen_resp_propl_match(t)}
  end

  defp gen_resp_cond_part(["body" | t]) do
    {:body_match, gen_resp_body_match(t)}
  end

  defp gen_resp_aggregation_cond(l) do
    [first_cond, second_cond] =
      l
      |> split_list(",")

    {gen_resp_cond_part(first_cond), gen_resp_cond_part(second_cond)}
  end

  defp gen_resp_code_match(["equals" | t]) do
    int_code = get_int(t)

    case int_code >= 100 and int_code <= 599 do
      false ->
        throw({:bad_value, :code_equal, int_code})

      true ->
        {:code_equal, int_code}
    end
  end

  defp gen_resp_code_match(["range" | [range_ini | [range_end]] = t]) do
    case range_ini >= 100 and range_ini <= 599 and range_end >= 100 and range_end <= 599 do
      false ->
        throw({:bad_value, :code_range, t})

      true ->
        {:code_range, get_int(range_ini), get_int(range_end)}
    end
  end

  defp gen_resp_code_match(["class" | t]) do
    class_int = get_int(t)

    case class_int >= 1 and class_int <= 5 do
      false ->
        throw({:bad_value, :code_class, class_int})

      true ->
        {:code_class, class_int}
    end
  end

  defp gen_resp_code_match(["regex" | [%Regex{} = r]]) do
    {:code_regex, r}
  end

  defp gen_resp_code_match(["regex" | t]) do
    throw({:bad_value, :code_regex, t})
  end

  defp gen_resp_propl_match(["has_key" | [t]]) do
    {:proplist_has_key, t}
  end

  defp gen_resp_propl_match(["has_key" | t]) do
    throw({:bad_value, :has_key, t})
  end

  defp gen_resp_propl_match(["contains" | [key | [value]]]) do
    {:proplist_contains, key, value}
  end

  defp gen_resp_propl_match(["contains" | t]) do
    throw({:bad_value, :contains, t})
  end

  defp gen_resp_body_match(["is" | [t]]) do
    {:string_exact, t}
  end

  defp gen_resp_body_match(["no_is" | [t]]) do
    {:string_iexact, t}
  end

  defp gen_resp_body_match(["contains" | [t]]) do
    {:string_contains, t}
  end

  defp gen_resp_body_match(["no_contains" | [t]]) do
    {:string_icontains, t}
  end

  defp gen_resp_body_match(["starts_with" | [t]]) do
    {:string_starts_with, t}
  end

  defp gen_resp_body_match(["no_starts_with" | [t]]) do
    {:string_istarts_with, t}
  end

  defp gen_resp_body_match(["ends_with" | [t]]) do
    {:string_ends_with, t}
  end

  defp gen_resp_body_match(["no_ends_with" | [t]]) do
    {:string_iends_with, t}
  end

  defp gen_resp_body_match(["regex" | [%Regex{} = t]]) do
    {:string_regex, t}
  end

  defp gen_resp_body_match(["regex" | [t]]) do
    {:bad_value, :regex_match, t}
  end

  defp gen_resp_body_match([_ | t]) do
    throw({:bad_format, :body_match, t})
  end

  defp gen_health_cond_part(["not" | t]) do
    {:not, gen_health_cond_part(t)}
  end

  defp gen_health_cond_part(["and" | t]) do
    {cond1, cond2} = gen_health_aggregation_cond(t)
    {:and, cond1, cond2}
  end

  defp gen_health_cond_part(["or" | t]) do
    {cond1, cond2} = gen_health_aggregation_cond(t)
    {:or, cond1, cond2}
  end

  defp gen_health_cond_part(["success" | t]) do
    {:successful_probes_match, gen_health_posint_match(t)}
  end

  defp gen_health_cond_part(["fails" | t]) do
    {:failed_probes_match, gen_health_posint_match(t)}
  end

  defp gen_health_aggregation_cond(l) do
    [first_cond, second_cond] =
      l
      |> split_list(",")

    {gen_health_cond_part(first_cond), gen_health_cond_part(second_cond)}
  end

  defp gen_health_posint_match(["equals" | [t]]) do
    {:pos_integer_equal, t}
  end

  defp gen_health_posint_match(["gt" | [t]]) do
    {:pos_integer_gt, t}
  end

  defp gen_health_posint_match(["gte" | [t]]) do
    {:pos_integer_gte, t}
  end

  defp gen_health_posint_match(["lt" | [t]]) do
    {:pos_integer_lt, t}
  end

  defp gen_health_posint_match(["lte" | [t]]) do
    {:pos_integer_lte, t}
  end

  defp gen_health_posint_match(["range" | t]) do
    {:pos_integer_range, t}
  end

  defp get_int(l) do
    try do
      [status_code] = l
      {value, _} = Integer.parse(status_code)
      value
    catch
      _ ->
        throw({:bad_format, :one_integer, l})
    end
  end

  @spec gets_healthcheck(list(atom())) :: Nurse.healthcheck()
  defp gets_healthcheck(keys) do
    keys
    |> get_hc_fields([])
    |> Nurse.Healthcheck.from_tuple()
  end

  @spec get_hc_fields(list(), list()) :: tuple()
  defp get_hc_fields([], acc) do
    [
      :proplists.get_value(:name, acc),
      :proplists.get_value(:health_status, acc),
      :proplists.get_value(:endpoint, acc),
      :proplists.get_value(:request, acc),
      :proplists.get_value(:check_delay, acc),
      :proplists.get_value(:retry_delay, acc),
      :proplists.get_value(:connection_timeout, acc),
      :proplists.get_value(:evaluation_interval, acc),
      :proplists.get_value(:response_condition, acc),
      :proplists.get_value(:response_timeout, acc),
      :proplists.get_value(:health_condition, acc),
      :proplists.get_value(:retry_condition, acc)
    ]
    |> List.to_tuple()
  end

  defp get_hc_fields([key | rest], acc) do
    val = get_hc_field(key)
    get_hc_fields(rest, [{key, val} | acc])
  end

  @spec get_ask_text(field :: atom()) :: String.t()
  defp get_ask_text(field) do
    field
    |> NurseCLIStatics.ask_text()
  end

  @spec get_hc_field(atom()) :: any()
  defp get_hc_field(:endpoint) do
    {get_hc_field(:scheme), get_hc_field(:request_hostname), get_hc_field(:request_port)}
  end

  defp get_hc_field(:request) do
    {get_hc_field(:request_method), get_hc_field(:request_headers), get_hc_field(:request_body)}
  end

  defp get_hc_field(field) do
    field
    |> get_ask_text
    |> ask_for
    |> check_quit
    |> maybe_retry(field)
  end

  @spec hc_to_summary({Nurse.uuid(), pid(), Nurse.healthcheck()}) :: tuple()
  defp hc_to_summary({
         id,
         pid,
         %Healthcheck{
           name: name,
           health_status: health_status,
           endpoint: {scheme, hostname, eport},
           request: {method, _headers, _body},
           evaluation_interval: evaluation_interval
         }
       }) do
    {id, "#{inspect(pid)}", name, Atom.to_string(health_status), method,
     scheme <> "://" <> hostname <> ":" <> Integer.to_string(eport),
     Integer.to_string(evaluation_interval)}
  end

  defp maybe_retry("h", field) do
    field
    |> help

    get_hc_field(field)
  end

  defp maybe_retry(str, field)
       when field == :connection_timeout or
              field == :evaluation_interval or
              field == :request_port or
              field == :response_timeout or
              field == :retry_delay or
              field == :check_delay do
    try do
      str
      |> convert_pos_integer(field)
    catch
      _ ->
        IO.puts("Error! Bad value. Printing help")
        field |> help
        get_hc_field(field)
    end
  end

  defp maybe_retry(str, :request_method = field) do
    try do
      str
      |> convert_method(field)
    catch
      _ ->
        IO.puts("Error! Bad value. Printing help")
        field |> help
        get_hc_field(field)
    end
  end

  defp maybe_retry(str, :request_headers = field) do
    try do
      str
      |> convert_headers(field)
    catch
      _ ->
        IO.puts("Error! Bad value. Printing help")
        field |> help
        get_hc_field(field)
    end
  end

  defp maybe_retry(str, :health_condition = field) do
    try do
      str
      |> convert_health_condition(field)
    catch
      _ ->
        IO.puts("Error! Bad value. Printing help")
        field |> help
        get_hc_field(field)
    end
  end

  defp maybe_retry(str, :retry_condition = field) do
    try do
      str
      |> convert_retry_condition(field)
    catch
      _ ->
        IO.puts("Error! Bad value. Printing help")
        field |> help
        get_hc_field(field)
    end
  end

  defp maybe_retry(str, :response_condition = field) do
    try do
      str
      |> convert_response_condition(field)
    catch
      {type, field, value} ->
        :io_lib.format("Error (~p)! Field ~p value ~p", [type, field, value])
        |> IO.puts()

        field |> help
        get_hc_field(field)
    end
  end

  defp maybe_retry(_str, :health_status) do
    IO.puts("Automatically setting health status to :undefined")
    :undefined
  end

  defp maybe_retry(str, _field) do
    str
  end

  defp merge_sizes([], [], new) do
    Enum.reverse(new)
  end

  defp merge_sizes([h1 | t1], [h2 | t2], acc) do
    merge_sizes(t1, t2, [
      if h1 > h2 do
        h1
      else
        h2
      end
      | acc
    ])
  end

  defp help(field) do
    text =
      field
      |> NurseCLIStatics.help()
      |> default("No help for this field.")

    text
    |> IO.puts()

    IO.gets("> Hit any key to continue...")

    text
    |> vsize
    |> Kernel.+(4)
    |> reset_lines
  end

  defp obtain_rows([], sizes, acc) do
    {acc, sizes}
  end

  defp obtain_rows([:error | rest], sizes, acc) do
    rest |> obtain_rows(sizes, acc)
  end

  defp obtain_rows([row | rest], sizes, acc) do
    {row_strs, actual_sizes} = row |> obtain_row
    new_sizes = actual_sizes |> merge_sizes(sizes, [])
    rest |> obtain_rows(new_sizes, acc ++ [row_strs])
  end

  @spec obtain_row(tuple()) :: tuple()
  defp obtain_row(hc) do
    hc
    |> hc_to_summary
    |> Tuple.to_list()
    |> List.foldl(
      {[], []},
      fn str, {strs, sizes} ->
        {strs ++ [to_str(str)], sizes ++ [String.length(to_str(str))]}
      end
    )
  end

  defp to_str(atom) when is_atom(atom) do
    Atom.to_string(atom)
  end

  defp to_str(integer) when is_integer(integer) do
    Integer.to_string(integer, 10)
  end

  defp to_str(str) do
    str
  end

  @spec print_hc_rows(list({Nurse.uuid(), pid(), Nurse.healthcheck()} | :error)) :: :ok
  defp print_hc_rows([]) do
    IO.puts("No healthcheck exists.")
  end

  defp print_hc_rows(rows) do
    {rows_strs, sizes} = rows |> obtain_rows([2, 3, 4, 13, 6, 8, 19], [])

    sps_sizes = sizes |> Enum.map(fn n -> n + 1 end)

    ["id", "pid", "name", "health_status", "method", "endpoint", "evaluation_interval"]
    |> Enum.zip(sps_sizes)
    |> Enum.map(fn {key, size} -> String.pad_trailing(key, size) end)
    |> List.foldl("", fn str, acc -> acc <> str end)
    |> IO.puts()

    rows_strs |> print_rows(sps_sizes)
  end

  defp print_rows([], _sizes) do
    IO.puts("")
  end

  defp print_rows([row | rest], sizes) do
    print_row(row, sizes)
    print_rows(rest, sizes)
  end

  defp print_row(row, sizes) do
    row
    |> Enum.zip(sizes)
    |> List.foldl("", fn {str, size}, acc -> acc <> String.pad_trailing(str, size) end)
    |> IO.puts()
  end

  defp vsize(text) do
    text |> String.split("\n") |> length |> Kernel.+(1)
  end

  defp reset_lines(n) do
    IO.puts("\e[#{n}A\e[1B\e[0J\e[1A")
  end

  ### ------------------------
  ### UTIL FUNCTIONS
  ### ------------------------
  defp split_list(l, c) do
    l
    |> :lists.sublist(2, length(l) - 2)
    |> Enum.chunk_by(fn split -> split != c end)
    |> Enum.reject(fn split -> split == [c] end)
  end

  defp tail([_h | t]), do: t
end
