defmodule Exhelp do
  @moduledoc """
  hello
  """

  def decompose(string) do
    string
    |> Code.string_to_quoted!()
    |> IEx.Introspection.decompose(__ENV__)
    |> Code.eval_quoted()
    |> elem(0)
  end

  def execute([type: true], args) do
    IEx.Introspection.t(String.to_atom(args |> Enum.at(0)))
  end

  def execute([behavior: true], args) do
    IEx.Introspection.b(String.to_atom(args |> Enum.at(0)))
  end

  def execute([open: true], args) do
    Open.open(decompose(args |> Enum.at(0)))
  end

  def execute(_, args) do
    IEx.Introspection.h(decompose(args |> Enum.at(0)))
  end

  def start_mix() do
    # file = get_executable() |> String.trim
    # IO.inspect(file)
    # next = :elixir_code_server.call({:acquire, file})
    # IO.inspect(next)
    # next = :elixir_compiler.file(file, fn _, _ -> :ok end)
    # IO.inspect(next)
    # next = :elixir_code_server.cast({:required, file})
    # IO.inspect(next)
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
    System.argv([])
    start_mix()
    System.cmd("mix", ["compile"])

    {opts, args, _} =
      OptionParser.parse(args,
        strict: [open: :boolean, type: :boolean, behavior: :boolean],
        aliases: [b: :behavior, t: :type]
      )

    IEx.configure(colors: [enabled: true])
    execute(opts, args)
  end
end
