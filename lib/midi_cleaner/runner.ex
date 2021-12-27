defmodule MidiCleaner.Runner do
  @callback run(Map.t()) :: :ok

  alias MidiCleaner.Config

  def run(config) do
    Config.validate(config)
  end
end
