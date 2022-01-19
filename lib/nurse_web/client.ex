defmodule NurseWeb.Client do
  @server Nurse.Leader

  import Nurse
  alias Nurse.Dets

  @spec create( Nurse.Healthcheck.t() ) :: :ok
  def create( healthcheck ) do
    GenServer.cast( Nurse.Leader, {:create, [healthcheck]} )
  end

  @spec remove( Nurse.uuid() ) :: :ok
  def remove( id ) do
    GenServer.cast( Nurse.Leader, {:remove, id} )
  end

  @spec get_all() :: list( Nurse.Healthcheck.t() )
  def get_all() do
    Nurse.table()
    |> Dets.table_to_list
  end

  @spec get( Nurse.uuid() ) :: Nurse.Healthcheck.t()
  def get( id ) do
    Nurse.table()
    |> Dets.get_one( id )
  end

end
