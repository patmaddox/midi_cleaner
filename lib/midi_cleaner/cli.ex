defmodule MidiCleaner.CLI do
  def main(args) do
    default_config()
    |> parse_options(args)
    |> run()
  end

  defp default_config do
    %{
      file_list: [],
      output: nil,
      remove_program_changes: false,
      remove_unchanging_cc_val0: false,
      set_midi_channel: nil
    }
  end

  defp parse_options(config, args) do
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

    config
    |> Map.merge(Map.new(options))
    |> Map.put(:file_list, file_list)
  end

  defp run(commands) do
    Application.get_env(:midi_cleaner, :runner).run(commands)
  end
end
