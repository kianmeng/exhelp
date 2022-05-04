defmodule Exhelp.Search do
  @moduledoc false

  @spec search(module() | {module(), atom()}) :: [String.t()]
  def search(candidate) when is_atom(candidate) do
    load_modules()
    |> Enum.filter(&matches_module?(&1, candidate))
    |> Enum.map(&Exhelp.Helpers.format_module/1)
  end

  def search({:module_not_found, fun}) when is_atom(fun) do
    (load_modules() -- [:module_not_found])
    |> Enum.map(&search({&1, fun}))
    |> Enum.concat()
  end

  def search({mod, fun}) when is_atom(mod) and is_atom(fun) do
    mod
    |> Exhelp.Helpers.exports()
    |> Enum.filter(fn {export, _} -> matches_function?(export, fun) end)
    |> Enum.map(fn {export, arity} ->
      format_mfa(mod, export, arity)
    end)
  end

  def search_function(modules, string) do
    Enum.map(modules, &Exhelp.Search.search({&1, string}))
    |> Enum.concat()
  end

  def list_all_modules() do
    load_modules()
    |> Enum.map(&Exhelp.Helpers.format_module/1)
  end

  defp load_modules() do
    modules =
      :code.all_loaded()
      |> Enum.map(fn {mod, _} -> mod end)

    (modules ++ get_modules_from_applications())
    |> Enum.sort()
    |> Enum.dedup()
  end

  defp matches_module?(module, candidate) do
    String.starts_with?("#{module}", "#{candidate}")
  end

  defp matches_function?(function, candidate) do
    String.starts_with?("#{function}", "#{candidate}")
  end

  defp format_mfa(mod, fun, arity) do
    "#{Exhelp.Helpers.format_module(mod)}.#{fun}/#{arity}"
  end

  defp get_modules_from_applications do
    for [app] <- loaded_applications(),
        {:ok, modules} = :application.get_key(app, :modules),
        module <- modules do
      module
    end
  end

  defp loaded_applications do
    # If we invoke :application.loaded_applications/0,
    # it can error if we don't call safe_fixtable before.
    # Since in both cases we are reaching over the
    # application controller internals, we choose to match
    # for performance.
    :ets.match(:ac_tab, {{:loaded, :"$1"}, :_})
  end
end
