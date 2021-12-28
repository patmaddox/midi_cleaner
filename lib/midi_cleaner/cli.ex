defmodule MidiCleaner.CLI do
  import MidiCleaner, only: [runner: 0]

  alias MidiCleaner.Config

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
  end
end
