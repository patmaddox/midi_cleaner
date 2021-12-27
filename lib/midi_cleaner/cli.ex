defmodule MidiCleaner.CLI do
  def main(args) do
    args
    |> parse_options()
    |> setup_commands()
    |> run()
  end

  defp parse_options(args) do
    {options, _} = OptionParser.parse!(args, strict: [pc: :boolean, cc0: :boolean, ch: :integer])
    Map.new(options)
  end

  defp setup_commands(opts) when opts == %{}, do: []

  defp setup_commands(%{pc: true} = opts),
    do: append_command(opts, :pc, &MidiCleaner.remove_program_changes/1)

  defp setup_commands(%{cc0: true} = opts),
    do: append_command(opts, :cc0, &MidiCleaner.remove_unchanging_cc_val0/1)

  defp setup_commands(%{ch: channel} = opts),
    do: append_command(opts, :ch, {&MidiCleaner.set_midi_channel/2, [channel]})

  defp append_command(opts, key, command) do
    remaining_opts = Map.delete(opts, key)
    [command | setup_commands(remaining_opts)]
  end

  defp run(commands) do
    Application.get_env(:midi_cleaner, :runner).run(commands)
  end
end
