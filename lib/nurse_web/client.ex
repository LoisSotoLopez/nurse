defmodule NurseWeb.Client do
  require Nurse

  @spec create(Nurse.Healthcheck.t()) :: :ok
  def create(healthcheck) do
    Nurse.create(healthcheck)
  end

  @spec remove(Nurse.uuid()) :: :ok
  def remove(id) do
    Nurse.delete(id)
  end

  @spec get_all() :: list(tuple() | :error) | :error
  def get_all() do
    Nurse.get_all()
  end

  @spec get(Nurse.uuid()) :: tuple() | :error
  def get(id) do
    Nurse.get(id)
  end
end
