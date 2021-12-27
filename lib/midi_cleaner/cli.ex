defmodule MidiCleaner.CLI do
  def main(args) when args == [], do: nil

  def main(args) do
    %{}
    |> parse_options(args)
    |> build_file_list()
    |> build_command_list()
    |> build_all_commands_list()
    |> run()
  end

  defp parse_options(config, args) do
    {options, filenames} =
      OptionParser.parse!(args, strict: [pc: :boolean, cc0: :boolean, ch: :integer, o: :string])

    config
    |> Map.put(:options, Map.new(options))
    |> Map.put(:filenames, filenames)
  end

  defp build_file_list(%{options: options} = config) when is_map_key(options, :o) do
    filenames =
      Enum.reduce(config.filenames, %{}, fn filename, filenames_map ->
        if Path.extname(filename) == ".mid" do
          Map.put(filenames_map, filename, "#{options.o}/#{filename}")
        else
          parent_dir = Path.dirname(filename)

          Path.wildcard("#{filename}/**/*.mid")
          |> Map.new(&{&1, options.o <> String.replace(&1, parent_dir, "")})
        end
      end)

    options = Map.delete(options, :o)
    %{config | filenames: filenames, options: options}
  end

  defp build_file_list(config) do
    filenames =
      Enum.reduce(config.filenames, %{}, fn filename, filenames_map ->
        if Path.extname(filename) == ".mid" do
          Map.put(filenames_map, filename, nil)
        else
          Path.wildcard("#{filename}/**/*.mid")
          |> Map.new(&{&1, nil})
        end
      end)

    %{config | filenames: filenames}
  end

  defp build_command_list(config) when not is_map_key(config, :commands) do
    config
    |> Map.put(:commands, [])
    |> build_command_list()
  end

  defp build_command_list(%{options: options} = config) when options == %{},
    do: Map.delete(config, :options)

  defp build_command_list(%{options: options, commands: commands} = config)
       when is_map_key(options, :ch) do
    commands = [{&MidiCleaner.set_midi_channel/2, [options.ch]} | commands]
    options = Map.delete(options, :ch)

    %{config | commands: commands, options: options}
    |> build_command_list()
  end

  defp build_command_list(%{options: options, commands: commands} = config)
       when is_map_key(options, :cc0) do
    commands = [(&MidiCleaner.remove_unchanging_cc_val0/1) | commands]
    options = Map.delete(options, :cc0)

    %{config | commands: commands, options: options}
    |> build_command_list()
  end

  defp build_command_list(%{options: options, commands: commands} = config)
       when is_map_key(options, :pc) do
    commands = [(&MidiCleaner.remove_program_changes/1) | commands]
    options = Map.delete(options, :pc)

    %{config | commands: commands, options: options}
    |> build_command_list()
  end

  defp build_all_commands_list(%{filenames: filenames, commands: commands}) do
    Enum.flat_map(filenames, fn {infile, outfile} ->
      process_file_commands = [
        {&MidiCleaner.read_file/1, [infile]},
        commands
      ]

      if outfile do
        process_file_commands =
          List.flatten([
            process_file_commands,
            {&MidiCleaner.write_file/2, [outfile]}
          ])

        path = Path.dirname(outfile)
        [[{&File.mkdir_p!/1, [path]}], process_file_commands]
      else
        [List.flatten(process_file_commands)]
      end
    end)
  end

  defp run(commands) do
    Application.get_env(:midi_cleaner, :runner).run(commands)
  end
end
