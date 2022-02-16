defmodule Nurse.Test.Structs.Healthcheck do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Nurse.Test.Generators

  describe "Nurse.Structs.Healthcheck" do
    test "creates a new struct" do
      assert Nurse.Healthcheck.new() |> Kernel.is_struct(Nurse.Healthcheck)
    end

    property "creates a proper struct from a tuple" do
      check all(
              name <- Generators.name(),
              health_status <- Generators.health_status(),
              endpoint <- Generators.endpoint(),
              request <- Generators.request(),
              check_delay <- Generators.check_delay(),
              retry_delay <- Generators.retry_delay(),
              evaluation_interval <- Generators.evaluation_interval(),
              response_condition <- Generators.response_condition(),
              health_condition <- Generators.health_condition(),
              retry_condition <- Generators.retry_condition()
            ) do
        healthcheck = %Nurse.Healthcheck{
          name: name,
          health_status: health_status,
          endpoint: endpoint,
          request: request,
          check_delay: check_delay,
          retry_delay: retry_delay,
          evaluation_interval: evaluation_interval,
          response_condition: response_condition,
          health_condition: health_condition,
          retry_condition: retry_condition
        }

        tuple =
          {name, health_status, endpoint, request, check_delay, retry_delay, evaluation_interval,
           response_condition, health_condition, retry_condition}

        assert tuple |> Nurse.Healthcheck.from_tuple() == healthcheck
      end
    end

    property "creates a proper tuple from a struct" do
      check all(healthcheck <- Generators.healthcheck()) do
        %Nurse.Healthcheck{
          name: name,
          health_status: health_status,
          endpoint: endpoint,
          request: request,
          check_delay: check_delay,
          retry_delay: retry_delay,
          evaluation_interval: evaluation_interval,
          response_condition: response_condition,
          health_condition: health_condition,
          retry_condition: retry_condition
        } = healthcheck

        tuple =
          {name, health_status, endpoint, request, check_delay, retry_delay, evaluation_interval,
           response_condition, health_condition, retry_condition}

        assert Nurse.Healthcheck.to_tuple(healthcheck) == tuple
      end
    end

    property "there and back again (struct first)" do
      check all(healthcheck <- Generators.healthcheck()) do
        assert healthcheck ==
                 healthcheck |> Nurse.Healthcheck.to_tuple() |> Nurse.Healthcheck.from_tuple()
      end
    end

    property "there and back again (tuple first)" do
      check all(
              name <- Generators.name(),
              health_status <- Generators.health_status(),
              endpoint <- Generators.endpoint(),
              request <- Generators.request(),
              check_delay <- Generators.check_delay(),
              retry_delay <- Generators.retry_delay(),
              evaluation_interval <- Generators.evaluation_interval(),
              response_condition <- Generators.response_condition(),
              health_condition <- Generators.health_condition(),
              retry_condition <- Generators.retry_condition()
            ) do
        tuple =
          {name, health_status, endpoint, request, check_delay, retry_delay, evaluation_interval,
           response_condition, health_condition, retry_condition}

        assert tuple == tuple |> Nurse.Healthcheck.from_tuple() |> Nurse.Healthcheck.to_tuple()
      end
    end

    test "updates struct fields" do
      healthcheck = %Nurse.Healthcheck{
        health_status: :starting
      }

      assert healthcheck |> Nurse.Healthcheck.update({:health_status, :stopped}) ==
               %Nurse.Healthcheck{health_status: :stopped}
    end
  end
end
