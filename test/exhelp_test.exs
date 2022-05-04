defmodule ExhelpTest do
  use ExUnit.Case

  test "decompose module" do
    assert Exhelp.decompose("Enum") == :"Elixir.Enum"
  end

  test "decompose Mod.fun" do
    assert Exhelp.decompose("String.contains?") == {:"Elixir.String", :contains?}
  end

  test "search for function" do
    modules = [Enum, Stream]
    assert Exhelp.search_function(modules, "reject") == ["Enum.reject/2", "Stream.reject/2"]
  end

  test "search for mod and fun" do
    assert Exhelp.search_for_module_and_function({Enum, :reject}) == ["Enum.reject/2"]
  end

  test "search for module returns list of strings" do
    output = Exhelp.Search.search(:c)
    assert Enum.all?(output, &is_binary/1)
  end

  test "search for module returns correct" do
    assert Exhelp.Search.search(Strea) == ["Stream"]
  end
end
