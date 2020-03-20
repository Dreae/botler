defmodule BotlerTest do
  use ExUnit.Case
  doctest Botler

  test "greets the world" do
    assert Botler.hello() == :world
  end
end
