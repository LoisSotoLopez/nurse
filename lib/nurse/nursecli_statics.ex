defmodule Nurse.NurseCLIStatics do
  defmacrop statics, do: "lib/nurse/statics/"
  defmacrop help_texts, do: statics() <> "help_texts/"
  defmacrop ask_texts, do: statics() <> "ask_texts/"

  @spec help(key :: atom()) :: binary() | :undefined
  def help(key) do
    help_texts()
    |> Kernel.<>(
      key
      |> Atom.to_string()
      |> Kernel.<>("_help.txt")
    )
    |> File.read()
    |> process_file_read
  end

  @spec ask_text(key :: atom()) :: binary()
  def ask_text(key) do
    ask_texts()
    |> Kernel.<>(
      key
      |> Atom.to_string()
      |> Kernel.<>("_ask.txt")
    )
    |> File.read()
    |> process_file_read
  end

  @spec process_file_read(file_out :: {:ok, binary()} | {:error, atom()}) :: binary() | :undefined
  defp process_file_read({:ok, str}) do
    str
  end

  defp process_file_read({:error, _error}) do
    :undefined
  end
end
