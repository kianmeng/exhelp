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

  defp execute([exports: true], [input]) do
    input
    |> decompose
    |> Exhelp.Helpers.print_exports()
  end

  defp execute([search: true], [input]) do
    input
    |> decompose()
    |> Exhelp.Search.search()
    |> Enum.each(&IO.puts/1)
  end

  defp execute([type: true], [input]) do
    input
    |> decompose
    |> Exhelp.Helpers.types()
  end

  defp execute([behavior: true], [input]) do
    input
    |> decompose
    |> Exhelp.Helpers.behaviours()
  end

  defp execute([open: true], [input]) do
    input
    |> decompose
    |> Exhelp.Helpers.open()
  end

  defp execute([], [input]) do
    input
    |> decompose
    |> Exhelp.Helpers.h()
  end

  defp execute([_, _ | _], _) do
    IO.puts("exh can only use one flag at a time.")
    display_help()
  end

  defp execute([], []) do
    display_help()
  end

  defp display_help() do
    IO.puts("exh")
  end

  defp start_mix() do
    if exec = get_executable() |> String.trim() do
      wrapper(fn -> Code.require_file(exec) end)
    end
  end

  defp wrapper(fun) do
    _ = fun.()
    :ok
  end

  defp get_executable() do
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
