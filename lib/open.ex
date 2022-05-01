defmodule Open do
  import IEx, only: [dont_display_result: 0]

  def open(module) when is_atom(module) do
    case open_mfa(module, :__info__, 1) do
      {source, nil, _} -> open(source)
      {_, tuple, _} -> open(tuple)
      :error -> puts_error("Could not open: #{inspect(module)}. Module is not available.")
    end

    dont_display_result()
  end

  def open({module, function}) when is_atom(module) and is_atom(function) do
    case open_mfa(module, function, :*) do
      {_, _, nil} ->
        puts_error(
          "Could not open: #{inspect(module)}.#{function}. Function/macro is not available."
        )

      {_, _, tuple} ->
        open(tuple)

      :error ->
        puts_error("Could not open: #{inspect(module)}.#{function}. Module is not available.")
    end

    dont_display_result()
  end

  def open({module, function, arity})
      when is_atom(module) and is_atom(function) and is_integer(arity) do
    case open_mfa(module, function, arity) do
      {_, _, nil} ->
        puts_error(
          "Could not open: #{inspect(module)}.#{function}/#{arity}. Function/macro is not available."
        )

      {_, _, tuple} ->
        open(tuple)

      :error ->
        puts_error(
          "Could not open: #{inspect(module)}.#{function}/#{arity}. Module is not available."
        )
    end

    dont_display_result()
  end

  def open({file, line}) when is_binary(file) and is_integer(line) do
    cond do
      not File.regular?(file) ->
        puts_error("Could not open: #{inspect(file)}. File is not available.")

      editor = System.get_env("ELIXIR_EDITOR") || System.get_env("EDITOR") ->
        command =
          if editor =~ "__FILE__" or editor =~ "__LINE__" do
            editor
            |> String.replace("__FILE__", inspect(file))
            |> String.replace("__LINE__", Integer.to_string(line))
          else
            "#{editor} #{inspect(file)}:#{line}"
          end

        IO.write(IEx.color(:eval_info, :os.cmd(String.to_charlist(command))))

      true ->
        puts_error(
          "Could not open: #{inspect(file)}. " <>
            "Please set the ELIXIR_EDITOR or EDITOR environment variables with the " <>
            "command line invocation of your favorite EDITOR."
        )
    end

    dont_display_result()
  end

  def open(invalid) do
    puts_error("Invalid arguments for open helper: #{inspect(invalid)}")
    dont_display_result()
  end

  defp open_mfa(module, fun, arity) do
    with {:module, _} <- Code.ensure_loaded(module),
         source when is_list(source) <- module.module_info(:compile)[:source] do
      source = rewrite_source(module, source)
      open_abstract_code(module, fun, arity, source)
    else
      _ -> :error
    end
  end

  defp escript_which_hack(module) do
    with {_, _, dir} <- :code.get_object_code(module) do
      if !String.contains?(to_string(dir), "escript") do
        dir
      else
        cmd =
          quote do
            IO.puts(:code.which(unquote(module)))
          end
          |> Macro.to_string()

        {dir, 0} = System.cmd("elixir", ["-e", cmd])
        dir |> String.trim() |> String.to_charlist()
      end
    else
      _ ->
        cmd =
          quote do
            IO.puts(:code.which(unquote(module)))
          end
          |> Macro.to_string()

        {dir, 0} = System.cmd("elixir", ["-e", cmd])
        dir |> String.trim() |> String.to_charlist()
    end
  end

  defp open_abstract_code(module, fun, arity, source) do
    fun = Atom.to_string(fun)

    with [_ | _] = beam <- escript_which_hack(module),
         {:ok, {_, [abstract_code: abstract_code]}} <- :beam_lib.chunks(beam, [:abstract_code]),
         {:raw_abstract_v1, code} <- abstract_code do
      {_, module_pair, fa_pair} =
        Enum.reduce(code, {source, nil, nil}, &open_abstract_code_reduce(&1, &2, fun, arity))

      {source, module_pair, fa_pair}
    else
      _ ->
        {source, nil, nil}
    end
  end

  defp open_abstract_code_reduce(entry, {file, module_pair, fa_pair}, fun, arity) do
    case entry do
      {:attribute, ann, :module, _} ->
        {file, {file, :erl_anno.line(ann)}, fa_pair}

      {:function, ann, ann_fun, ann_arity, _} ->
        case Atom.to_string(ann_fun) do
          "MACRO-" <> ^fun when arity == :* or ann_arity == arity + 1 ->
            {file, module_pair, fa_pair || {file, :erl_anno.line(ann)}}

          ^fun when arity == :* or ann_arity == arity ->
            {file, module_pair, fa_pair || {file, :erl_anno.line(ann)}}

          _ ->
            {file, module_pair, fa_pair}
        end

      _ ->
        {file, module_pair, fa_pair}
    end
  end

  @elixir_apps ~w(eex elixir ex_unit iex logger mix)a
  @otp_apps ~w(kernel stdlib)a
  @apps @elixir_apps ++ @otp_apps

  defp escript_dir_hack(app) do
    cmd =
      quote do
        IO.puts(Application.app_dir(unquote(app)))
      end
      |> Macro.to_string()

    {dir, 0} = System.cmd("elixir", ["-e", cmd])
    dir |> String.trim()
  end

  defp rewrite_source(module, source) do
    case :application.get_application(module) do
      {:ok, app} when app in @apps ->
        Path.join(escript_dir_hack(app), rewrite_source(source))

      _ ->
        beam_path = :code.which(module)

        if is_list(beam_path) and List.starts_with?(beam_path, :code.root_dir()) do
          app_vsn = beam_path |> Path.dirname() |> Path.dirname() |> Path.basename()
          Path.join([:code.root_dir(), "lib", app_vsn, rewrite_source(source)])
        else
          List.to_string(source)
        end
    end
  end

  defp rewrite_source(source) do
    {in_app, [lib_or_src | _]} =
      source
      |> Path.split()
      |> Enum.reverse()
      |> Enum.split_while(&(&1 not in ["lib", "src"]))

    Path.join([lib_or_src | Enum.reverse(in_app)])
  end

  defp puts_error(string) do
    IO.puts(IEx.color(:eval_error, string))
  end
end
