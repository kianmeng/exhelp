defmodule ExhelpTest do
  use ExUnit.Case

  test "decompose module" do
    assert Exhelp.decompose("Enum") == :"Elixir.Enum"
  end
end
