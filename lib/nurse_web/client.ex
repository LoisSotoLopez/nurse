defmodule NurseWeb.Client do
  require Nurse
  alias Nurse.Dets

  @spec create(Nurse.Healthcheck.t()) :: :ok
  def create(healthcheck) do
    GenServer.cast(Nurse.Leader, {:create, [healthcheck]})
  end

  @spec remove(Nurse.uuid()) :: :ok
  def remove(id) do
    GenServer.cast(Nurse.Leader, {:remove, id})
  end

  @spec get_all() :: list(tuple())
  def get_all() do
    Nurse.table()
    |> Dets.table_to_list()
  end

  @spec get(Nurse.uuid()) :: tuple()
  def get(id) do
    [hc] =
      Nurse.table()
      |> Dets.lookup(id)
    hc
  end
end
