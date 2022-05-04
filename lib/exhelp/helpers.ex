defmodule Exhelp.Helpers do
  @moduledoc false

  def decompose(ast) do
    IEx.Introspection.decompose(ast, __ENV__) 
  end
end
