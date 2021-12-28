defmodule MidiCleaner.Runner do
  import MidiCleaner, only: [midi_cleaner: 0]

  @callback run(Map.t()) :: :ok

  alias MidiCleaner.{Config, FileProcessor}

  def run(config) do
    with :ok <- Config.validate(config) do
      Config.each_dir(config, &make_output_dir(&1, config))

      Config.each_file(config, fn {infile, outfile} ->
        file_processor().process_file(config, infile, outfile)
      end)

      :ok
    else
      errors -> errors
    end
  end

  defp make_output_dir(dir, config) do
    output_dir = Path.join(config.output, dir)
    midi_cleaner().make_dir(output_dir)
  end

  defp file_processor(), do: Application.get_env(:midi_cleaner, :file_processor)
end
