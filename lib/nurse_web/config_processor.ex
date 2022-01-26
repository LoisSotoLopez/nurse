defmodule NurseWeb.ConfigProcessor do
  alias NurseWeb.HealthcheckConfig

  @type error() :: String.t()
  @type yaml() :: String.t()

  @spec process(yaml()) :: {:ok, HealthcheckConfig.t()} | {:error, error()}
  def process(yaml) do
    try do
      case YamlElixir.read_from_string(yaml) do
        {:ok, map} when is_map(map) ->
          case HealthcheckConfig.from_map(map) do
            {:missing_key, key} ->
              {:error, "Error! Missing configuration for key \"" <> key <> "\""}

            config ->
              {:ok, config}
          end

        {:ok, _other} ->
          {:error, "Could not parse a mapping from provided text to a proper configuration."}

        {:error, error} ->
          {:error, process_error(error)}
      end
    catch
      {:error, error} ->
        error_str = "Error! Yaml error: " <> error
        {:error, error_str}
    end
  end

  @spec process_error(any()) :: error()
  defp process_error(%YamlElixir.ParsingError{
         column: col,
         line: line,
         message: _,
         type: :unexpected_token
       }) do
    "Error! Unexpected token on line " <>
      Integer.to_string(line) <> ", column " <> Integer.to_string(col) <> "."
  end
end
