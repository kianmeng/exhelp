defmodule Exhelp.Search do
  @moduledoc false

  @spec search(atom() | {atom(), atom()}) :: [String.t()]
  def search(module) when is_atom(module) do
    load_modules()
    |> Enum.filter(fn mod -> String.starts_with?("#{mod}", "#{module}") end)
    |> Enum.map(fn mod -> "#{Exhelp.Helpers.format_module(mod)}" end)
  end

  defp load_modules() do
    :code.all_loaded()
    |> Enum.map(fn {mod, _} -> mod end)
  end
end
