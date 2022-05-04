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
end
