defmodule MidiCleaner.MixProject do
  use Mix.Project

  def project do
    [
      app: :midi_cleaner,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MidiCleaner.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:midifile, git: "https://github.com/jimm/elixir-midifile.git", ref: "7eac20c"},
      {:mox, "~> 1.0", only: :test}
    ]
  end

  defp escript do
    [
      main_module: MidiCleaner.CLI,
      app: nil,
      path: "escript/midi_cleaner"
    ]
  end
end
