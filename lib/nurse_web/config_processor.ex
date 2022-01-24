defmodule NurseWeb.ConfigProcessor do
  alias NurseWeb.HealthcheckConfig

  @type error() :: String.t()
  @type yaml() :: String.t()

  @spec process( yaml() ) :: {:ok, HealthcheckConfig.t() } | {:error, error() }
  def process(yaml) do
    try do
      case YamlElixir.read_from_string(yaml) do
        {:ok, map} when is_map(map) ->
          case HealthcheckConfig.from_map(map) do
            {:missing_key, key} ->
              {:error, "Error! Missing configuration for key \"" <> Atom.to_string(key) <> "\""}
            {:duplicated_key, key} ->
              {:error, "Error! Duplicated configuration for key \"" <> Atom.to_string(key) <> "\""}
            {:bad_type, key, _value} ->
              {:error, "Error! \"" <> Atom.to_string(key) <> "\" has wrong type."}
            config ->
              config
          end
        {:ok, other} ->
          {:error, "Could not parse a mapping from provided text to a proper configuration."}
      end
    catch
      {:error, error} ->
        error_str = "Error! Yaml error: " <> error
        IO.puts error_str
        {:error, error_str}
    end
  end

end
