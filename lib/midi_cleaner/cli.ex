defmodule MidiCleaner.CLI do
  import MidiCleaner, only: [runner: 0]

  alias MidiCleaner.Config
  alias MidiCleaner.Commands.{RemoveProgramChanges, RemoveUnchangingCcVal0, SetMidiChannel}

  def main(args) do
    parse_options(args)
    |> Config.new()
    |> runner().run()
  end

  defp parse_options(args) do
    {options, file_list} =
      OptionParser.parse!(
        args,
        strict: [
          output: :string,
          remove_program_changes: :boolean,
          remove_unchanging_cc_val0: :boolean,
          set_midi_channel: :integer
        ]
      )

    Map.new(options)
    |> Map.put(:file_list, file_list)
    |> Map.put(:processors, [])
    |> extract_processors()
  end

  defp extract_processors(%{remove_program_changes: true, processors: processors} = options) do
    options
    |> Map.delete(:remove_program_changes)
    |> Map.put(:processors, [RemoveProgramChanges | processors])
    |> extract_processors()
  end

  defp extract_processors(%{remove_unchanging_cc_val0: true, processors: processors} = options) do
    options
    |> Map.delete(:remove_unchanging_cc_val0)
    |> Map.put(:processors, [RemoveUnchangingCcVal0 | processors])
    |> extract_processors()
  end

  defp extract_processors(%{set_midi_channel: channel, processors: processors} = options) do
    options
    |> Map.delete(:set_midi_channel)
    |> Map.put(:processors, [SetMidiChannel.make_processor(channel) | processors])
    |> extract_processors()
  end

  defp extract_processors(options), do: options
end
