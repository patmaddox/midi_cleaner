defmodule MidiCleaner.Runner do
  @callback run(Map.t()) :: :ok

  use GenServer

  import MidiCleaner, only: [midi_cleaner: 0, file_processor: 0]

  alias MidiCleaner.{Config, FileList}

  def new(config), do: GenServer.start_link(__MODULE__, config)

  def run(%Config{} = config) do
    {:ok, pid} = new(config)
    :ok = run(pid, :infinity)
    :ok = GenServer.stop(pid)
  end

  def run(pid, timeout \\ 5000), do: GenServer.call(pid, :run, timeout)

  @impl true
  def init(config), do: {:ok, config}

  @impl true
  def handle_call(:run, _from, config) do
    with :ok <- Config.validate(config) do
      make_output_dirs(config)
      process_files(config)

      {:reply, :ok, config}
    else
      errors -> {:reply, errors, config}
    end
  end

  defp make_output_dirs(config) do
    FileList.dirs(config.file_list)
    |> Task.async_stream(fn dir ->
      output_dir = Path.join(config.output, dir)
      midi_cleaner().make_dir(output_dir)
    end)
    |> Enum.each(& &1)
  end

  defp process_files(config) do
    FileList.files(config.file_list)
    |> Task.async_stream(fn {infile, outfile} ->
      :ok = file_processor().process_file(config, infile, outfile)
    end)
    |> Enum.each(& &1)
  end
end
