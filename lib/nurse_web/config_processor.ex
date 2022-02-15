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
            {:error, err} ->
              {:error, process_error(err)}

            config ->
              {:ok, config}
          end

        {:ok, _other} ->
          {:error, "Could not parse a mapping from provided text to a proper configuration."}

        {:error, err} ->
          {:error, process_error(err)}
      end
    catch
      {:error, error} ->
        error_str = "Error! Yaml error: " <> error
        {:error, error_str}
    end
  end

  @spec process_error(tuple() | term()) :: error()
  defp process_error(%YamlElixir.ParsingError{
         column: col,
         line: line,
         message: _,
         type: :unexpected_token
       }) do
    "Error! Unexpected token on line " <>
      Integer.to_string(line) <> ", column " <> Integer.to_string(col) <> "."
  end

  defp process_error({:bad_input, key, value}) do
    "Error! Value \"#{value}\" for key \"#{key}\" is of wrong type"
  end

  defp process_error({:missing_key, key}) do
    "Error! Missing configuration for key \"#{key}\""
  end

  defp process_error({:bad_config, key, val}) do
    "Error! Either key \"#{key}\" was not expected or value \"#{val}\" is not a valid for such key."
  end
end
