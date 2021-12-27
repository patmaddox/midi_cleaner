defmodule MidiCleaner.CLI do
  def main(args) do
    args
    |> parse_options()
    |> setup_commands()
    |> run()
  end

  defp parse_options(args) do
    {options, filenames} =
      OptionParser.parse!(args, strict: [pc: :boolean, cc0: :boolean, ch: :integer, o: :string])

    {Map.new(options), filenames}
  end

  defp setup_commands({opts, []}), do: setup_commands(opts)

  defp setup_commands({opts, [filename]}), do: setup_commands({opts, filename})

  defp setup_commands({%{o: path} = opts, filenames}) when is_list(filenames) do
    Enum.flat_map(filenames, fn filename ->
      output_filename = "#{path}/#{filename}"
      opts = Map.put(opts, :o, output_filename)
      target_dir = Path.dirname(opts.o)

      [
        [{&File.mkdir_p!/1, [target_dir]}],
        setup_commands({opts, filename})
      ]
    end)
  end

  defp setup_commands({opts, filenames}) when is_list(filenames) do
    Enum.map(filenames, fn filename ->
      setup_commands({opts, filename})
    end)
  end

  defp setup_commands({opts, filename}),
    do: append_command(opts, {&MidiCleaner.read_file/1, [filename]})

  defp setup_commands(opts) when opts == %{}, do: []

  defp setup_commands(%{pc: true} = opts),
    do: append_command(opts, :pc, &MidiCleaner.remove_program_changes/1)

  defp setup_commands(%{cc0: true} = opts),
    do: append_command(opts, :cc0, &MidiCleaner.remove_unchanging_cc_val0/1)

  defp setup_commands(%{ch: channel} = opts),
    do: append_command(opts, :ch, {&MidiCleaner.set_midi_channel/2, [channel]})

  defp setup_commands(%{o: outfile} = opts),
    do: append_command(opts, :o, {&MidiCleaner.write_file/2, [outfile]})

  defp append_command(opts, command), do: [command | setup_commands(opts)]

  defp append_command(opts, key, command), do: Map.delete(opts, key) |> append_command(command)

  defp run(commands) do
    Application.get_env(:midi_cleaner, :runner).run(commands)
  end
end
