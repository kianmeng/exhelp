defmodule Exhelp do
  @moduledoc """
  hello
  """

  def decompose(string) do
    string
    |> Code.string_to_quoted!()
    |> Exhelp.Helpers.decompose()
    |> Code.eval_quoted()
    |> elem(0)
  end

  defp load_modules() do
    :code.all_loaded()
    |> Enum.map(fn {mod, _} -> mod end)
  end

  def search_for_module_and_function({mod, fun}) do
    mod
    |> IEx.Autocomplete.exports()
    |> Enum.filter(fn {export, _arity} -> String.starts_with?("#{export}", "#{fun}") end)
    |> Enum.map(fn {export, arity} ->
      "#{Inspect.Algebra.to_doc(mod, %Inspect.Opts{})}.#{export}/#{arity}"
    end)
  end

  def search_function(modules, string) do
    Enum.map(modules, &search_for_module_and_function({&1, string}))
    |> Enum.concat()
  end

  def search({Kernel, fun}) do
    load_modules()
    |> search_function(fun)
    |> Enum.each(&IO.puts/1)
  end

  def search({mod, fun}) do
    search_for_module_and_function({mod, fun})
    |> Enum.each(&IO.puts/1)
  end

  def search(module) do
    load_modules()
    |> Enum.filter(fn mod -> String.starts_with?("#{mod}", "#{module}") end)
    |> Enum.each(&IO.inspect/1)
  end

  def execute([exports: true], args) do
    IEx.Helpers.exports(decompose(args |> Enum.at(0)))
  end

  def execute([search: true], [arg]) do
    arg
    |> decompose()
    |> search()
  end

  def execute([type: true], args) do
    IEx.Introspection.t(decompose(args |> Enum.at(0)))
  end

  def execute([behavior: true], args) do
    IEx.Introspection.b(decompose(args |> Enum.at(0)))
  end

  def execute([open: true], args) do
    Open.open(decompose(args |> Enum.at(0)))
  end

  def execute([], args) do
    IEx.Introspection.h(decompose(args |> Enum.at(0)))
  end

  def execute([_, _ | _], _) do
    IO.puts("exh can only use one flag at a time.")
    display_help()
  end

  def display_help() do
    IO.puts("exh")
  end

  def start_mix() do
    if exec = get_executable() |> String.trim() do
      wrapper(fn -> Code.require_file(exec) end)
    end
  end

  def wrapper(fun) do
    _ = fun.()
    :ok
  end

  def get_executable() do
    {path, 0} = System.cmd("elixir", ["-e", "IO.puts(System.find_executable(\"mix\"))"])
    path
  end

  def main(args) do
    {opts, args, _} =
      OptionParser.parse(args,
        strict: [
          open: :boolean,
          type: :boolean,
          behavior: :boolean,
          script: :string,
          exports: :boolean,
          search: :boolean
        ],
        aliases: [b: :behavior, t: :type, S: :script, o: :open, s: :search]
      )

    {mix, rest} = Keyword.pop(opts, :script)

    if mix do
      System.argv([])
      start_mix()
      System.cmd("mix", ["compile"])
    end

    IEx.configure(colors: [enabled: true])
    execute(rest, args)
  end
end
