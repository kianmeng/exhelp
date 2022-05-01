defmodule Exhelp.MixProject do
  use Mix.Project

  def project do
    [
      app: :exhelp,
      version: "0.1.0",
      elixir: "~> 1.13",
      escript: escript(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def escript() do
    [main_module: Exhelp, strip_beams: false, embed_elixir: true]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :iex, :mix, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
    ]
  end
end
