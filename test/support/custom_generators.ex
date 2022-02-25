defmodule Nurse.Test.Generators do
  use ExUnitProperties

  @dialyzer :no_return

  @http_methods [
    :get,
    :post,
    :put,
    :patch,
    :delete,
    :options,
    :head
  ]

  @health_status [
    :starting,
    :healthy,
    :retrying,
    :unhealthy,
    :stopped
  ]

  def binary_logical_operator(), do: StreamData.member_of([:and, :or])

  def body(), do: StreamData.string(:ascii)

  def check_delay(), do: StreamData.positive_integer()

  def retry_delay(), do: StreamData.positive_integer()

  def code_class(), do: StreamData.integer(1..5)

  def code_match() do
    ExUnitProperties.gen all(
                           status_code <- status_code(),
                           code_class <- code_class(),
                           regex <- regex()
                         ) do
      [
        {:code_equal, status_code},
        {:code_range, status_code, status_code},
        {:code_class, code_class},
        {:code_regex, regex}
      ]
      |> StreamData.member_of()
    end
  end

  def connection_timeout(), do: StreamData.positive_integer()

  def endpoint() do
    ExUnitProperties.gen all(
                           scheme <- scheme(),
                           hostname <- hostname(),
                           port <- port()
                         ) do
      {scheme, hostname, port}
    end
  end

  def evaluation_interval(), do: StreamData.positive_integer()

  def failed_probes, do: StreamData.positive_integer()

  def headers() do
    {StreamData.string(:alphanumeric), StreamData.string(:alphanumeric)}
    |> StreamData.tuple()
    |> StreamData.list_of()
  end

  def healthcheck() do
    ExUnitProperties.gen all(
                           name <- name(),
                           health_status <- health_status(),
                           endpoint <- endpoint(),
                           request <- request(),
                           check_delay <- check_delay(),
                           retry_delay <- retry_delay(),
                           connection_timeout <- connection_timeout(),
                           evaluation_interval <- evaluation_interval(),
                           response_condition <- response_condition(),
                           response_timeout <- response_timeout(),
                           health_condition <- health_condition(),
                           retry_condition <- retry_condition()
                         ) do
      %Nurse.Healthcheck{
        name: name,
        health_status: health_status,
        endpoint: endpoint,
        request: request,
        check_delay: check_delay,
        retry_delay: retry_delay,
        connection_timeout: connection_timeout,
        evaluation_interval: evaluation_interval,
        response_condition: response_condition,
        response_timeout: response_timeout,
        health_condition: health_condition,
        retry_condition: retry_condition
      }
    end
  end

  def health_aggregation() do
    ExUnitProperties.gen all(
                           health_leaf <- health_leaf(),
                           health_leaf_2 <- health_leaf(),
                           unary_logical_operator <- unary_logical_operator(),
                           binary_logical_operator <- binary_logical_operator()
                         ) do
      [
        {unary_logical_operator, health_leaf},
        {binary_logical_operator, health_leaf, health_leaf_2}
      ]
      |> StreamData.member_of()
    end
  end

  def health_condition(), do: StreamData.one_of([health_aggregation(), health_leaf()])

  def health_leaf() do
    ExUnitProperties.gen all(pos_integer_match <- pos_integer_match()) do
      [
        {:successful_probes_match, pos_integer_match},
        {:failed_probes_match, pos_integer_match}
      ]
      |> StreamData.member_of()
    end
  end

  def health_status(), do: StreamData.member_of(@health_status)

  def hostname(), do: StreamData.binary()

  def method(), do: StreamData.member_of(@http_methods)

  def name(), do: StreamData.atom(:alphanumeric)

  def proplist_match() do
    ExUnitProperties.gen all(
                           tuple_key <- StreamData.string(:ascii),
                           tuple_value <- StreamData.string(:ascii)
                         ) do
      [
        {:proplist_has_key, tuple_key},
        {:proplist_contains, {tuple_key, tuple_value}}
      ]
      |> StreamData.member_of()
    end
  end

  def port(), do: StreamData.integer(0..65535)

  def pos_integer_match() do
    ExUnitProperties.gen all(
                           pos_integer <- StreamData.positive_integer(),
                           pos_integer_2 <- StreamData.positive_integer()
                         ) do
      [
        {:pos_integer_equal, pos_integer},
        {:pos_integer_gt, pos_integer},
        {:pos_integer_gte, pos_integer},
        {:pos_integer_lt, pos_integer},
        {:pos_integer_lte, pos_integer},
        {:pos_integer_range, pos_integer, pos_integer_2}
      ]
      |> StreamData.member_of()
    end
  end

  def probes_results(), do: {successful_probes(), failed_probes()} |> StreamData.tuple()

  def regex() do
    ExUnitProperties.gen all(pseudo_regex <- StreamData.string(:alphanumeric)) do
      ~r/#{pseudo_regex}/
    end
  end

  def request() do
    ExUnitProperties.gen all(
                           method <- method(),
                           headers <- headers(),
                           body <- body()
                         ) do
      {method, headers, body}
    end
  end

  def response() do
    ExUnitProperties.gen all(
                           status_code <- status_code(),
                           headers <- headers(),
                           body <- body()
                         ) do
      {status_code, headers, body}
    end
  end

  def response_aggregation() do
    ExUnitProperties.gen all(
                           response_leaf <- response_leaf(),
                           response_leaf_2 <- response_leaf(),
                           unary_logical_operator <- unary_logical_operator(),
                           binary_logical_operator <- binary_logical_operator()
                         ) do
      [
        {unary_logical_operator, response_leaf},
        {binary_logical_operator, response_leaf, response_leaf_2}
      ]
      |> StreamData.member_of()
    end
  end

  def response_condition(), do: StreamData.one_of([response_aggregation(), response_leaf()])

  def response_leaf() do
    ExUnitProperties.gen all(
                           code_match <- code_match(),
                           proplist_match <- proplist_match(),
                           string_match <- string_match()
                         ) do
      [
        {:status_code_match, code_match},
        {:headers_match, proplist_match},
        {:body_match, string_match}
      ]
      |> StreamData.member_of()
    end
  end

  def response_timeout(), do: StreamData.positive_integer()

  def retry_condition(), do: health_condition()

  def scheme(), do: StreamData.member_of([:http])

  def status_code(), do: StreamData.integer(100..599)

  def string_match() do
    ExUnitProperties.gen all(
                           string <- StreamData.string(:ascii),
                           regex <- regex()
                         ) do
      [
        {:string_exact, string},
        {:string_iexact, string},
        {:string_contains, string},
        {:string_icontains, string},
        {:string_starts_with, string},
        {:string_istarts_with, string},
        {:string_ends_with, string},
        {:string_iends_with, string},
        {:string_regex, regex}
      ]
      |> StreamData.member_of()
    end
  end

  def successful_probes, do: StreamData.positive_integer()

  def unary_logical_operator(), do: StreamData.constant(:not)
end
