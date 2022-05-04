defmodule Exhelp.Helpers do
  @moduledoc false

  def decompose(ast) do
    IEx.Introspection.decompose(ast, __ENV__)
  end

  def format_module(atom) do
    Inspect.Algebra.to_doc(atom, %Inspect.Opts{})
  end
end
