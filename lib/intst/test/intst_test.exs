defmodule IntstTest do
  use ExUnit.Case
  doctest Intst

  test "greets the world" do
    assert Intst.hello() == :world
  end
end
