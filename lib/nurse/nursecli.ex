defmodule Nurse.NurseCLI do
  alias Nurse.Healthcheck


  ### ------------------------
  ### EXTERNAL FUNCTIONS
  ### ------------------------
  def get_healthcheck() do
    IO.puts("\nRetrieving healtcheck...")
    id =
      IO.gets("Healthcheck id? ")
      |> String.trim

    [GenServer.call(Nurse.Leader, {:get, id})]
    |> print_hc_rows()
  end

  def get_healthchecks() do
    IO.puts("\nRetrieving all healthchecks...")
    GenServer.call(Nurse.Leader, :get_all)
    |> print_hc_rows()
  end

  ### ------------------------
  ### INTERNAL FUNCTIONS
  ### ------------------------
  @spec print_hc_rows(list({Nurse.uuid(), pid(), Nurse.healthcheck()}) | [:error]) :: :ok
  defp print_hc_rows([:error]) do
    IO.puts("Not found.")
  end
  defp print_hc_rows([]) do
    IO.puts("No healthcheck exists.")
  end
  defp  print_hc_rows(rows) do
    {rows_strs, sizes} = rows |> obtain_rows([2,3,4,13,6,8,19], [])

    sps_sizes = sizes |> Enum.map(fn n -> n+1 end)
    ["id", "pid", "name", "health_status", "method", "endpoint", "evaluation_interval"]
    |> Enum.zip(sps_sizes)
    |> Enum.map(fn {key, size} -> String.pad_trailing(key, size) end)
    |> List.foldl("", fn str, acc -> acc <> str end)
    |> IO.puts

    rows_strs |> print_rows(sps_sizes)
  end

  defp obtain_rows([], sizes, acc) do
    {acc, sizes}
  end
  defp obtain_rows([row | rest], sizes, acc) do
    {row_strs, actual_sizes} = row |> obtain_row
    new_sizes = actual_sizes |> merge_sizes(sizes, [])
    rest |> obtain_rows(new_sizes, acc ++ [row_strs])
  end

  defp merge_sizes([], [], new) do
    Enum.reverse(new)
  end
  defp merge_sizes([h1 | t1], [h2 | t2], acc) do
    merge_sizes(t1, t2, [if h1 > h2 do h1 else h2 end| acc])
  end

  @spec obtain_row(tuple()) :: :ok
  defp obtain_row(hc) do
    hc
    |> hc_to_summary
    |> Tuple.to_list
    |> List.foldl(
        {[], []},
        fn str, {strs, sizes} ->
          {strs ++ [str], sizes ++ [String.length(str)]}
        end)
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
    |> IO.puts
  end

  @spec hc_to_summary({Nurse.uuid(), pid(), Nurse.healthcheck()}) :: :ok
  defp hc_to_summary({
    id,
    pid,
    %Healthcheck{
      name: name,
      health_status: health_status,
      endpoint: {scheme, hostname, eport},
      request: {method, _headers, _body},
      evaluation_interval: evaluation_interval
    }}
  ) do
    {id, "#{inspect pid}", name, Atom.to_string(health_status), method, scheme <> "://" <> hostname <> ":" <> Integer.to_string(eport), Integer.to_string(evaluation_interval)}
  end
end
