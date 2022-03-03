defmodule Nurse do
  @moduledoc """
  Nurse
  """

  @table :healthchecks

  defmacro table, do: @table

  @type uuid :: String.t()
  @type name :: String.t()
  @type table :: atom()

  @type check_delay :: pos_integer()
  @type retry_delay :: pos_integer()
  @type evaluation_interval :: pos_integer()

  @type health_status :: :starting | :healthy | :retrying | :unhealthy | :stopped

  @type endpoint :: {scheme(), hostname(), eport()}
  @type scheme :: String.t()
  @type hostname :: binary()
  @type eport :: :inet.port_number()

  @type connection_timeout :: pos_integer()
  @type response_timeout :: pos_integer()
  @type request :: {method(), headers(), body()}
  @type response :: {status_code(), headers(), body()}
  @type method :: HTTPoison.Request.method()
  @type headers :: HTTPoison.Request.headers()
  @type body :: HTTPoison.Request.body()
  @type status_code :: 100..599

  @type unary_logical_operator :: :not
  @type binary_logical_operator :: :and | :or

  @type response_condition :: response_aggregation() | response_leaf()
  @type response_aggregation ::
          {unary_logical_operator(), response_condition()}
          | {binary_logical_operator(), response_condition(), response_condition()}
  @type response_leaf :: status_code_match() | headers_match() | body_match()

  @type status_code_match :: {:status_code_match, code_match()}
  @type headers_match :: {:headers_match, proplist_match()}
  @type body_match :: {:body_match, string_match()}
  @type code_match ::
          {:code_equal, status_code()}
          | {:code_range, status_code(), status_code()}
          | {:code_class, 1..5}
          | {:code_regex, Regex.t()}
  @type proplist_match ::
          {:proplist_has_key, String.t()}
          | {:proplist_contains, {String.t(), String.t()}}
  @type string_match ::
          {:string_exact, String.t()}
          | {:string_iexact, String.t()}
          | {:string_contains, String.t()}
          | {:string_icontains, String.t()}
          | {:string_starts_with, String.t()}
          | {:string_istarts_with, String.t()}
          | {:string_ends_with, String.t()}
          | {:string_iends_with, String.t()}
          | {:string_regex, Regex.t()}

  @type probes_results :: {successful_probes(), failed_probes()}
  @type successful_probes :: pos_integer()
  @type failed_probes :: pos_integer()

  @type health_condition :: health_aggregation() | health_leaf()
  @type health_aggregation ::
          {unary_logical_operator(), health_condition()}
          | {binary_logical_operator(), health_condition(), health_condition()}
  @type health_leaf :: successful_probes_match() | failed_probes_match()
  @type successful_probes_match :: {:successful_probes_match, pos_integer_match()}
  @type failed_probes_match :: {:failed_probes_match, pos_integer_match()}
  @type pos_integer_match ::
          {:pos_integer_equal, pos_integer()}
          | {:pos_integer_gt, pos_integer()}
          | {:pos_integer_gte, pos_integer()}
          | {:pos_integer_lt, pos_integer()}
          | {:pos_integer_lte, pos_integer()}
          | {:pos_integer_range, pos_integer(), pos_integer()}

  @type retry_condition :: health_condition()

  @type healthcheck :: Nurse.Healthcheck.t()
end
