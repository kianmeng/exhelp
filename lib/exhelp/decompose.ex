defmodule Exhelp.Decompose do
  def decompose({:/, _, [call, arity]} = term, context) do
    case Macro.decompose_call(call) do
      {_mod, :__info__, []} when arity == 1 ->
        {:{}, [], [Module, :__info__, 1]}

      {mod, fun, []} ->
        {:{}, [], [mod, fun, arity]}

      {fun, []} ->
        {:{}, [], [find_decompose_fun_arity(fun, arity, context), fun, arity]}

      _ ->
        term
    end
  end

  def decompose(call, context) do
    case Macro.decompose_call(call) do
      {_mod, :__info__, []} ->
        Macro.escape({Module, :__info__, 1})

      {mod, fun, []} ->
        {mod, fun}

      {fun, []} ->
        {find_decompose_fun(fun, context), fun}

      _ ->
        call
    end
  end

  defp find_decompose_fun(fun, context) do
    find_import(fun, context.functions) || find_import(fun, context.macros) ||
      find_special_form(fun) || :module_not_found
  end

  defp find_decompose_fun_arity(fun, arity, context) do
    pair = {fun, arity}

    find_import(pair, context.functions) || find_import(pair, context.macros) ||
      find_special_form(pair) || :module_not_found
  end

  defp find_import(pair, context) when is_tuple(pair) do
    Enum.find_value(context, fn {mod, functions} ->
      if pair in functions, do: mod
    end)
  end

  defp find_import(fun, context) do
    Enum.find_value(context, fn {mod, functions} ->
      if Keyword.has_key?(functions, fun), do: mod
    end)
  end

  defp find_special_form(pair) when is_tuple(pair) do
    special_form_function? = pair in Kernel.SpecialForms.__info__(:functions)
    special_form_macro? = pair in Kernel.SpecialForms.__info__(:macros)

    if special_form_function? or special_form_macro?, do: Kernel.SpecialForms
  end

  defp find_special_form(fun) do
    special_form_function? = Keyword.has_key?(Kernel.SpecialForms.__info__(:functions), fun)
    special_form_macro? = Keyword.has_key?(Kernel.SpecialForms.__info__(:macros), fun)

    if special_form_function? or special_form_macro?, do: Kernel.SpecialForms
  end
end
