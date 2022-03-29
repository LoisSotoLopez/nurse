defmodule Nurse.Test.Condition.Response do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Nurse.Test.Generators

  describe "Nurse.Condition.Response" do
    property "receives and returns properly typed arguments" do
      check all(
              response <- Generators.response_tuple(),
              response_condition <- Generators.response_condition()
            ) do
        assert response |> Nurse.Condition.Response.check(response_condition) |> is_boolean()
      end
    end

    property "simple status code equal" do
      check all(response <- Generators.response()) do
        {status_code, _headers, _body} = response
        response_condition = {:status_code_match, {:code_equal, status_code}}

        assert response |> Nurse.Condition.Response.check(response_condition)
      end
    end

    property "simple status code range" do
      check all(response <- Generators.response()) do
        {status_code, _headers, _body} = response
        response_condition = {:status_code_match, {:code_range, status_code - 1, status_code + 1}}

        assert response |> Nurse.Condition.Response.check(response_condition)
      end
    end

    property "simple status code class" do
      check all(response <- Generators.response()) do
        {status_code, _headers, _body} = response

        response_condition =
          {:status_code_match, {:code_class, status_code |> Integer.digits() |> List.first()}}

        assert response |> Nurse.Condition.Response.check(response_condition)
      end
    end

    property "simple status code regex" do
      check all(response <- Generators.response()) do
        response_condition = {:status_code_match, {:code_regex, ~r/[0-5][0-9]{2}/}}

        assert response |> Nurse.Condition.Response.check(response_condition)
      end
    end

    property "simple proplist has_key" do
      check all(
              {_status_code, headers, _body} = response <- Generators.response(),
              !Enum.empty?(headers)
            ) do
        response_condition =
          {:headers_match,
           {:proplist_has_key, headers |> List.first() |> Tuple.to_list() |> List.first()}}

        assert response |> Nurse.Condition.Response.check(response_condition)
      end
    end

    property "simple proplist contains" do
      check all(
              {_status_code, headers, _body} = response <- Generators.response(),
              !Enum.empty?(headers)
            ) do
        response_condition = {:headers_match, {:proplist_contains, headers |> List.first()}}

        assert response |> Nurse.Condition.Response.check(response_condition)
      end
    end

    property "simple string exact" do
      check all({_status_code, _headers, body} = response <- Generators.response()) do
        response_condition = {:body_match, {:string_exact, body}}

        assert response |> Nurse.Condition.Response.check(response_condition)
      end
    end

    property "simple string iexact" do
      check all({_status_code, _headers, body} = response <- Generators.response()) do
        response_condition = {:body_match, {:string_iexact, body |> String.upcase()}}

        assert response |> Nurse.Condition.Response.check(response_condition)
      end
    end

    property "simple string contains" do
      check all({_status_code, _headers, body} = response <- Generators.response()) do
        response_condition = {:body_match, {:string_contains, body |> String.slice(1..3)}}

        assert response |> Nurse.Condition.Response.check(response_condition)
      end
    end

    property "simple string icontains" do
      check all({_status_code, _headers, body} = response <- Generators.response()) do
        response_condition =
          {:body_match, {:string_icontains, body |> String.slice(1..3) |> String.upcase()}}

        assert response |> Nurse.Condition.Response.check(response_condition)
      end
    end

    property "simple string starts_with" do
      check all(
              {_status_code, _headers, body} = response <- Generators.response(),
              !(body |> String.length() == 0)
            ) do
        response_condition = {:body_match, {:string_starts_with, body |> String.first()}}

        assert response |> Nurse.Condition.Response.check(response_condition)
      end
    end

    property "simple string istarts_with" do
      check all(
              {_status_code, _headers, body} = response <- Generators.response(),
              !(body |> String.length() == 0)
            ) do
        response_condition =
          {:body_match, {:string_istarts_with, body |> String.first() |> String.upcase()}}

        assert response |> Nurse.Condition.Response.check(response_condition)
      end
    end

    property "simple string ends_with" do
      check all(
              {_status_code, _headers, body} = response <- Generators.response(),
              !(body |> String.length() == 0)
            ) do
        response_condition = {:body_match, {:string_ends_with, body |> String.last()}}

        assert response |> Nurse.Condition.Response.check(response_condition)
      end
    end

    property "simple string iends_with" do
      check all(
              {_status_code, _headers, body} = response <- Generators.response(),
              !(body |> String.length() == 0)
            ) do
        response_condition =
          {:body_match, {:string_iends_with, body |> String.last() |> String.upcase()}}

        assert response |> Nurse.Condition.Response.check(response_condition)
      end
    end

    property "simple string regex_with" do
      check all(response <- Generators.response()) do
        response_condition = {:body_match, {:string_regex, ~r/[\x00-\x7F]*/}}

        assert response |> Nurse.Condition.Response.check(response_condition)
      end
    end

    property "aggregated condition" do
      check all({status_code, _headers, body} = response <- Generators.response()) do
        response_condition = {
          :and,
          {:status_code_match, {:code_range, status_code - 1, status_code + 1}},
          {:or, {:headers_match, {:proplist_has_key, "foo"}},
           {:body_match, {:string_icontains, body}}}
        }

        assert response |> Nurse.Condition.Response.check(response_condition)
      end
    end
  end
end
