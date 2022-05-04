defmodule Exhelp.Helpers do
  @moduledoc false

  def decompose(ast) do
    Exhelp.Decompose.decompose(ast, __ENV__)
  end

  def format_module(atom) do
    Code.Identifier.inspect_as_atom(atom)
  end

  def exports(module) do
    IEx.Autocomplete.exports(module)
  end

  def print_exports(module) do
    IEx.Helpers.exports(module)
  end

  def types(module) do
    IEx.Introspection.t(module)
  end

  def behaviours(module) do
    IEx.Introspection.b(module)
  end

  def open(input) do
 Open.open(input)
  end

  def h(input) do
IEx.Introspection.h(input)
  end
end
