defmodule Nurse.Leader do
  use GenServer
  alias Nurse.Dets

  # -------------------------------------------------------------------------------
  # Start/Stop functions
  # -------------------------------------------------------------------------------
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  # -------------------------------------------------------------------------------
  # GenServer callbacks
  # -------------------------------------------------------------------------------
  @impl true
  def init(table) do
    {:ok, table}
  end

  @impl true
  def handle_cast({method, args}, table) do
    __MODULE__ |> Kernel.spawn(method, [table | args])
    {:noreply, table}
  end

  # -------------------------------------------------------------------------------
  # Internal exports
  # -------------------------------------------------------------------------------
  @spec create(Nurse.table(), Nurse.healthcheck()) :: :ok | :error
  def create(table, healthcheck) do
    id = UUID.uuid1()
    row = {id, :undefined, healthcheck}

    table
    |> Dets.insert(row)
  end

  @spec start(Nurse.table(), Nurse.uuid()) :: :ok | :error
  def start(table, id) do
    [{id, _old_pid, healthcheck} | _rest] = table |> Dets.lookup(id)

    pid = Nurse.Worker |> Kernel.spawn_link(:start_link, [healthcheck])

    table
    |> Dets.insert({id, pid, healthcheck})
  end

  @spec update(Nurse.table(), Nurse.uuid(), Nurse.healthcheck()) :: :ok | :error
  def update(table, id, healthcheck) do
    [{id, pid, _old_healthcheck} | _rest] = table |> Dets.lookup(id)

    table
    |> Dets.insert({id, pid, healthcheck})
  end

  @spec stop(Nurse.table(), Nurse.uuid()) :: :ok | :error
  def stop(table, id) do
    [{id, pid, old_healthcheck} | _rest] = table |> Dets.lookup(id)

    healthcheck = old_healthcheck |> Nurse.Healthcheck.update({:health_status, :stopped})

    pid
    |> Process.exit(:kill)

    table
    |> Dets.insert({id, :undefined, healthcheck})
  end

  @spec delete(Nurse.table(), Nurse.uuid()) :: :ok | :error
  def delete(table, id) do
    lookup = table |> Dets.lookup(id)

    case lookup do
      :error -> :ok
      [{_id, :undefined, _healthcheck} | _rest] -> :ok
      _otherwise -> stop(table, id)
    end

    table
    |> Dets.delete(id)
  end
end
