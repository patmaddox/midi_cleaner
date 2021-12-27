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
      output_filename =
        if Map.has_key?(opts, :path_prefix) do
          short_path = String.replace(filename, Path.dirname(opts.path_prefix), "")
          "#{path}#{short_path}"
        else
          "#{path}/#{filename}"
        end

      opts = Map.delete(opts, :path_prefix)
      opts = Map.put(opts, :o, output_filename)
      target_dir = Path.dirname(output_filename)

      [
        [{&File.mkdir_p!/1, [target_dir]}],
        setup_commands({opts, filename})
      ]
    end)
  end

  defp setup_commands({%{path_prefix: _} = opts, filenames}) do
    opts = Map.delete(opts, :path_prefix)
    setup_commands({opts, filenames})
  end

  defp setup_commands({opts, filenames}) when is_list(filenames) do
    Enum.map(filenames, fn filename ->
      setup_commands({opts, filename})
    end)
  end

  defp setup_commands({opts, filename}) do
    if Path.extname(filename) == ".mid" do
      append_command(opts, {&MidiCleaner.read_file/1, [filename]})
    else
      filenames = Path.wildcard("#{filename}/**/*.mid")
      opts = Map.put(opts, :path_prefix, filename)
      setup_commands({opts, filenames})
    end
  end

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
