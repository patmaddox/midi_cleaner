defmodule MidiCleaner.Runner do
  @callback run(Map.t()) :: :ok

  use GenServer

  import MidiCleaner, only: [midi_cleaner: 0]

  alias MidiCleaner.Config

  def new(config), do: GenServer.start_link(__MODULE__, config)

  @impl true
  def init(config), do: {:ok, config}

  def run(target) when is_pid(target), do: GenServer.call(target, :run)

  @impl true
  def handle_call(:run, _from, config) do
    with :ok <- Config.validate(config) do
      Config.each_dir(config, &make_output_dir(&1, config))

      Config.each_file(config, fn {infile, outfile} ->
        file_processor().process_file(config, infile, outfile)
      end)

      {:reply, :ok, config}
    else
      errors -> {:reply, errors, config}
    end
  end

  defp make_output_dir(dir, config) do
    output_dir = Path.join(config.output, dir)
    midi_cleaner().make_dir(output_dir)
  end

  defp file_processor(), do: Application.get_env(:midi_cleaner, :file_processor)
end
