defmodule ExhelpTest do
  use ExUnit.Case

  test "decompose module" do
    assert Exhelp.decompose("Enum") == :"Elixir.Enum"
  end

  test "decompose Mod.fun" do
    assert Exhelp.decompose("String.contains?") == {:"Elixir.String", :contains?}
  end

  test "search for module returns list of strings" do
    output = Exhelp.Search.search(:c)
    assert Enum.all?(output, &is_binary/1)
  end

  test "search for module returns correct" do
    assert Exhelp.Search.search(Strea) == ["Stream", "Stream.Reducers"]
  end

  test "search for mod and fun returns list of strings" do
    assert Enum.all?(Exhelp.Search.search({Enum, :map}), &is_binary/1)
  end

  test "search for mod and fun returns correct" do
    assert Exhelp.Search.search({Enum, :reject}) == ["Enum.reject/2"]
  end

  test "search for fun returns list of strings" do
    assert Enum.all?(Exhelp.Search.search({:module_not_found, :map}), &is_binary/1)
  end

  test "search for fun returns correct" do
    assert Exhelp.Search.search({:module_not_found, :make_bool}) == [":beam_types.make_boolean/0"]
  end
end
