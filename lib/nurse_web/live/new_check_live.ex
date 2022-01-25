defmodule NurseWeb.NewCheckLive do
  use NurseWeb, :live_view

  alias Nurse.Healthcheck
  alias NurseWeb.Client

  require Logger

  def mount(_params, _session, socket) do
    socket =
      assign(socket, new_condition_type: "none")
      |> assign(condition_map: %{})
      |> assign(
        check_params: %{
          :check_name => "",
          :check_delay => "",
          :connection_timeout => "",
          :evaluation_interval => "",
          :request_method => "",
          :request_body => "",
          :request_header => "",
          :request_hostname => "",
          :request_port => "",
          :request_scheme => "",
          :response_timeout => "",
          :retry_delay => ""
        }
      )
      |> assign(bad_input_msg: "")

    {:ok, socket}
  end

  def handle_event(
        "add_condition",
        %{
          "condition-type" => "simple",
          "condition-id" => parent_condition_id,
          "condition-side" => condition_side,
          "value" => _value
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.put_new_son_of(
        socket.assigns.condition_map,
        parent_condition_id,
        "simple",
        condition_side
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "add_condition",
        %{
          "condition-type" => condition_type,
          "condition-id" => parent_condition_id,
          "condition-side" => side,
          "value" => _value
        },
        socket
      ) do
    new_map =
      socket.assigns.condition_map
      |> Nurse.CondMap.put_new_son_of(parent_condition_id, condition_type, side)

    socket =
      assign(socket, condition_map: new_map)
      |> assign(bad_input_msg: "")

    {:noreply, socket}
  end

  def handle_event(
        "set_condition_type",
        %{
          "new-condition-type" => new_condition_type,
          "new-condition-for-condition" => condition_id,
          "value" => _value
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(socket.assigns.condition_map, condition_id, %{
        condition_type: new_condition_type
      })

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_status_code_match",
        %{
          "status-code-match" => status_code_match,
          "new-condition-for-condition" => condition_id,
          "value" => _value
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(socket.assigns.condition_map, condition_id, %{
        status_code_match: status_code_match
      })

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_headers_match",
        %{
          "headers-match" => headers_match,
          "new-condition-for-condition" => condition_id,
          "value" => _value
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(socket.assigns.condition_map, condition_id, %{
        headers_match: headers_match
      })

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_body_match",
        %{
          "body-match" => body_match,
          "new-condition-for-condition" => condition_id,
          "value" => _value
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(socket.assigns.condition_map, condition_id, %{
        body_match: body_match
      })

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  # status_code_match_equality_val
  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "negate_new_condition" => _is_negation,
          "status_code_match_equality_val" => status_code_match_equality_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{
          is_negation: true,
          status_code_match_equality_val: status_code_match_equality_val,
          is_done: true
        }
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "status_code_match_equality_val" => status_code_match_equality_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{
          is_negation: false,
          status_code_match_equality_val: status_code_match_equality_val,
          is_done: true
        }
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  # ---

  # status_code_match_code_range_val
  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "negate_new_condition" => _is_negation,
          "status_code_match_code_range_val" => status_code_match_code_range_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{
          is_negation: true,
          status_code_match_code_range_val: status_code_match_code_range_val,
          is_done: true
        }
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "status_code_match_code_range_val" => status_code_match_code_range_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{
          is_negation: false,
          status_code_match_code_range_val: status_code_match_code_range_val,
          is_done: true
        }
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  # ---

  # status_code_match_code_class_val
  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "negate_new_condition" => _is_negation,
          "status_code_match_code_class_val" => status_code_match_code_class_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{
          is_negation: true,
          status_code_match_code_class_val: status_code_match_code_class_val,
          is_done: true
        }
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "status_code_match_code_class_val" => status_code_match_code_class_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{
          is_negation: false,
          status_code_match_code_class_val: status_code_match_code_class_val,
          is_done: true
        }
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  # ---

  # status_code_match_regex_val
  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "negate_new_condition" => _is_negation,
          "status_code_match_regex_val" => status_code_match_regex_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{
          is_negation: true,
          status_code_match_regex_val: status_code_match_regex_val,
          is_done: true
        }
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "status_code_match_regex_val" => status_code_match_regex_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{
          is_negation: false,
          status_code_match_regex_val: status_code_match_regex_val,
          is_done: true
        }
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  # ---

  # headers_match_has_header_key_val
  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "negate_new_condition" => _is_negation,
          "headers_match_has_header_key_val" => headers_match_has_header_key_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{
          is_negation: true,
          headers_match_has_header_key_val: headers_match_has_header_key_val,
          is_done: true
        }
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "headers_match_has_header_key_val" => headers_match_has_header_key_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{
          is_negation: false,
          headers_match_has_header_key_val: headers_match_has_header_key_val,
          is_done: true
        }
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  # ---

  # headers_match_has_header_val
  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "negate_new_condition" => _is_negation,
          "headers_match_has_header_val" => headers_match_has_header_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{
          is_negation: true,
          headers_match_has_header_val: headers_match_has_header_val,
          is_done: true
        }
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "headers_match_has_header_val" => headers_match_has_header_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{
          is_negation: false,
          headers_match_has_header_val: headers_match_has_header_val,
          is_done: true
        }
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  # ---

  # body_match_exact_val
  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "negate_new_condition" => _is_negation,
          "body_match_exact_val" => body_match_exact_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{is_negation: true, body_match_exact_val: body_match_exact_val, is_done: true}
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_condition_values",
        %{"condition-id" => condition_id, "body_match_exact_val" => body_match_exact_val},
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{is_negation: false, body_match_exact_val: body_match_exact_val, is_done: true}
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  # ---

  # body_match_iexact_val
  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "negate_new_condition" => _is_negation,
          "body_match_iexact_val" => body_match_iexact_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{is_negation: true, body_match_iexact_val: body_match_iexact_val, is_done: true}
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_condition_values",
        %{"condition-id" => condition_id, "body_match_iexact_val" => body_match_iexact_val},
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{is_negation: false, body_match_iexact_val: body_match_iexact_val, is_done: true}
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  # ---

  # body_match_contains_val
  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "negate_new_condition" => _is_negation,
          "body_match_contains_val" => body_match_contains_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{is_negation: true, body_match_contains_val: body_match_contains_val, is_done: true}
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_condition_values",
        %{"condition-id" => condition_id, "body_match_contains_val" => body_match_contains_val},
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{is_negation: false, body_match_contains_val: body_match_contains_val, is_done: true}
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  # ---

  # body_match_contains_val
  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "negate_new_condition" => _is_negation,
          "body_match_icontains_val" => body_match_icontains_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{is_negation: true, body_match_icontains_val: body_match_icontains_val, is_done: true}
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_condition_values",
        %{"condition-id" => condition_id, "body_match_icontains_val" => body_match_icontains_val},
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{is_negation: false, body_match_icontains_val: body_match_icontains_val, is_done: true}
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  # ---

  # body_match_contains_val
  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "negate_new_condition" => _is_negation,
          "body_match_starts_with_val" => body_match_starts_with_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{
          is_negation: true,
          body_match_starts_with_val: body_match_starts_with_val,
          is_done: true
        }
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "body_match_starts_with_val" => body_match_starts_with_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{
          is_negation: false,
          body_match_starts_with_val: body_match_starts_with_val,
          is_done: true
        }
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  # ---

  # body_match_contains_val
  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "negate_new_condition" => _is_negation,
          "body_match_istarts_with_val" => body_match_istarts_with_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{
          is_negation: true,
          body_match_istarts_with_val: body_match_istarts_with_val,
          is_done: true
        }
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "body_match_istarts_with_val" => body_match_istarts_with_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{
          is_negation: false,
          body_match_istarts_with_val: body_match_istarts_with_val,
          is_done: true
        }
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  # ---

  # body_match_contains_val
  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "negate_new_condition" => _is_negation,
          "body_match_ends_with_val" => body_match_ends_with_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{is_negation: true, body_match_ends_with_val: body_match_ends_with_val, is_done: true}
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_condition_values",
        %{"condition-id" => condition_id, "body_match_ends_with_val" => body_match_ends_with_val},
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{is_negation: false, body_match_ends_with_val: body_match_ends_with_val, is_done: true}
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  # ---

  # body_match_iends_with_val
  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "negate_new_condition" => _is_negation,
          "body_match_iends_with_val" => body_match_iends_with_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{is_negation: true, body_match_iends_with_val: body_match_iends_with_val, is_done: true}
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "body_match_iends_with_val" => body_match_iends_with_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{is_negation: false, body_match_iends_with_val: body_match_iends_with_val, is_done: true}
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  # ---

  # body_match_regex_val
  def handle_event(
        "set_condition_values",
        %{
          "condition-id" => condition_id,
          "negate_new_condition" => _is_negation,
          "body_match_regex_val" => body_match_regex_val
        },
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{is_negation: true, body_match_regex_val: body_match_regex_val, is_done: true}
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  def handle_event(
        "set_condition_values",
        %{"condition-id" => condition_id, "body_match_regex_val" => body_match_regex_val},
        socket
      ) do
    new_map =
      Nurse.CondMap.update_condition_params(
        socket.assigns.condition_map,
        condition_id,
        %{is_negation: false, body_match_regex_val: body_match_regex_val, is_done: true}
      )

    socket = assign(socket, condition_map: new_map)
    {:noreply, socket}
  end

  # ---
  def handle_event(
        "save_check_configuration",
        %{
          "check_name" => check_name,
          "check_delay" => check_delay,
          "connection_timeout" => connection_timeout,
          "evaluation_interval" => evaluation_interval,
          "request_method" => request_method,
          "request_body" => request_body,
          "request_header" => request_header,
          "request_hostname" => request_hostname,
          "request_port" => request_port,
          "request_scheme" => request_scheme,
          "response_timeout" => response_timeout,
          "retry_delay" => retry_delay
        },
        socket
      ) do
    params = %{
      :check_name => check_name,
      :check_delay => check_delay,
      :connection_timeout => connection_timeout,
      :evaluation_interval => evaluation_interval,
      :request_method => request_method,
      :request_body => request_body,
      :request_header => request_header,
      :request_hostname => request_hostname,
      :request_port => request_port,
      :request_scheme => request_scheme,
      :response_timeout => response_timeout,
      :retry_delay => retry_delay
    }

    socket = assign(socket, check_params: params)
    {:noreply, socket}
  end

  def handle_event(
        "submit_check_configuration",
        params,
        socket
      ) do
    case Nurse.CondMap.validate(socket.assigns.condition_map) do
      true ->
        inputs = validate_input_values(params)

        case inputs do
          {:field, fieldname} ->
            socket = assign(socket, bad_input_msg: "Field " <> fieldname <> " is invalid")
            {:noreply, socket}

          true ->
            %{
              "check_name" => check_name,
              "check_delay" => check_delay,
              "connection_timeout" => connection_timeout,
              "evaluation_interval" => evaluation_interval,
              "request_method" => request_method,
              "request_body" => request_body,
              "request_header" => request_header,
              "request_hostname" => request_hostname,
              "request_port" => request_port,
              "request_scheme" => request_scheme,
              "response_timeout" => response_timeout,
              "retry_delay" => retry_delay
            } = params

            health_condition = []
            retry_condition = []
            response_condition = socket.assigns.condition_map

            {check_name, :starting, {request_scheme, request_hostname, request_port},
             {request_method, request_header, request_body}, check_delay, retry_delay,
             connection_timeout, evaluation_interval, response_condition, response_timeout,
             health_condition, retry_condition}
            |> Healthcheck.from_tuple()
            |> Client.create()

            {:noreply, redirect(socket, to: "/all-checks")}
        end

      false ->
        socket =
          assign(socket,
            bad_input_msg:
              "Condition tree needs conditions in all its branches, and can not be empty."
          )

        {:noreply, socket}
    end
  end

  defp validate_input_values(
         %{
           "check_delay" => _check_delay,
           "connection_timeout" => _connection_timeout,
           "evaluation_interval" => _evaluation_interval,
           "request_body" => _request_body,
           "request_header" => _request_header,
           "request_hostname" => _request_hostname,
           "request_port" => _request_port,
           "request_scheme" => _request_scheme,
           "response_timeout" => _response_timeout,
           "retry_delay" => _retry_delay
         } = properties
       ) do
    properties
    |> Map.to_list()
    |> validate_multi()
  end

  defp validate_input_values(_params) do
    {:field, "missing_params"}
  end

  defp validate_multi([]), do: true

  defp validate_multi([{key, val} | t]) do
    case validate_one(key |> String.to_atom(), val) do
      true ->
        validate_multi(t)

      _ ->
        {:field, key}
    end
  end

  defp validate_one(:check_delay, value) do
    try do
      value
      |> String.to_integer()

      true
    rescue
      _error -> false
    end
  end

  defp validate_one(:connection_timeout, value) do
    try do
      value
      |> String.to_integer()

      true
    rescue
      _error -> false
    end
  end

  defp validate_one(:evaluation_interval, value) do
    try do
      value
      |> String.to_integer()

      true
    rescue
      _error -> false
    end
  end

  defp validate_one(_any, _value), do: true
end
