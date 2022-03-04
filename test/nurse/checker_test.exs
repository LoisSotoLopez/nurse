defmodule Nurse.Test.Checker do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Nurse.Test.Generators

  describe "Nurse.Checker" do
    property "check_responses receives and returns properly typed arguments" do
      check all(
              responses <- StreamData.list_of(Generators.response_tuple()),
              response_condition <- Generators.response_condition()
            ) do
        {successful, failed} = Nurse.Checker.check_responses(responses, response_condition)
        assert successful >= 0 and failed >= 0
        assert successful + failed == responses |> Enum.count()
      end
    end

    property "check_health receives and returns properly typed arguments" do
      check all(
              probes_results <- Generators.probes_results(),
              health_condition <- Generators.health_condition()
            ) do
        status = Nurse.Checker.check_health(probes_results, health_condition)
        assert [:healthy, :unhealthy] |> Enum.member?(status)
      end
    end

    property "check_retry receives and returns properly typed arguments" do
      check all(
              probes_results <- Generators.probes_results(),
              retry_condition <- Generators.retry_condition()
            ) do
        status = Nurse.Checker.check_health(probes_results, retry_condition)
        assert [:healthy, :unhealthy] |> Enum.member?(status)
      end
    end
  end
end
