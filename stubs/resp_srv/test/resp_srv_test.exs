defmodule RespSrvTest do
  use ExUnit.Case
  doctest RespSrv

  test "greets the world" do
    assert RespSrv.hello() == :world
  end
end
