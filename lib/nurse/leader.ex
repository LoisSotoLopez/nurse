defmodule Nurse.Leader do
  use GenServer
  require Logger
  alias Nurse.Dets

  # -------------------------------------------------------------------------------
  # Start/Stop functions
  # -------------------------------------------------------------------------------
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def terminate(_reason, table) do
    table |> Dets.close()
  end

  # -------------------------------------------------------------------------------
  # GenServer callbacks
  # -------------------------------------------------------------------------------
  @impl true
  def init(table) do
    Nurse.Dets.open_or_create(table, [])
    {:ok, table}
  end

  @impl true
  def handle_cast({method, args}, table) do
    __MODULE__ |> Kernel.spawn(method, [table | args])
    {:noreply, table}
  end

  @impl true
  def handle_call({method, args}, _from, table) do
    reply = __MODULE__ |> Kernel.apply(method, [table | args])
    {:reply, reply, table}
  end

  # -------------------------------------------------------------------------------
  # Internal exports
  # -------------------------------------------------------------------------------
  @spec create(Nurse.table(), Nurse.uuid(), Nurse.healthcheck()) :: :ok | :error
  def create(table, id, healthcheck) do
    row = {id, :undefined, healthcheck}

    Logger.info("[leader] Creating new healthcheck with id #{inspect(id)}")

    table
    |> Dets.insert(row)

    table
    |> start(id)
  end

  @spec start(Nurse.table(), Nurse.uuid()) :: :ok | :error
  def start(table, id) do
    {id, _old_pid, healthcheck} = table |> Dets.lookup(id)

    Logger.info("[leader] Starting worker for healthcheck with id #{inspect(id)}")
    pid = Nurse.Worker |> Kernel.spawn_link(:start_link, [id])

    table
    |> Dets.insert({id, pid, healthcheck})
  end

  @spec update(Nurse.table(), Nurse.uuid(), Nurse.healthcheck()) :: :ok | :error
  def update(table, id, healthcheck) do
    {id, pid, _old_healthcheck} = table |> Dets.lookup(id)

    Logger.info("[leader] Updating healthcheck with id #{inspect(id)}")

    table
    |> Dets.insert({id, pid, healthcheck})
  end

  @spec stop(Nurse.table(), Nurse.uuid()) :: :ok | :error
  def stop(table, id) do
    {id, pid, old_healthcheck} = table |> Dets.lookup(id)

    healthcheck = old_healthcheck |> Nurse.Healthcheck.update({:health_status, :stopped})

    Logger.info("[leader] Stopping worker for healthcheck with id #{inspect(id)}")

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
      {_id, :undefined, _healthcheck} -> :ok
      _otherwise -> stop(table, id)
    end

    table
    |> Dets.delete(id)
  end

  @spec get(Nurse.table(), Nurse.uuid()) :: tuple | :error
  def get(table, id) do
    table |> Dets.lookup(id)
  end

  @spec get_all(Nurse.table()) :: list(tuple()) | :error
  def get_all(table) do
    table |> Dets.table_to_list()
  end
end
