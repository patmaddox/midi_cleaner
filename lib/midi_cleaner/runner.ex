defmodule MidiCleaner.Runner do
  @callback run(Map.t()) :: :ok

  use GenServer

  import MidiCleaner, only: [midi_cleaner: 0, file_processor: 0]

  alias MidiCleaner.{Config, FileList}

  def new(config) do
    state = %{
      config: config,
      processors: [],
      status: :new
    }

    GenServer.start_link(__MODULE__, state)
  end

  def run(%Config{} = config) do
    {:ok, pid} = new(config)
    :ok = run(pid, :infinity)
  end

  def run(pid, timeout \\ 5000), do: GenServer.call(pid, :run, timeout)

  def status(pid), do: GenServer.call(pid, :status)

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call(:run, _from, %{config: config} = state) do
    with :ok <- Config.validate(config) do
      make_output_dirs(config)
      new_processors = process_files(config)

      {:reply, :ok, %{state | status: :running, processors: new_processors}}
    else
      errors -> {:reply, errors, %{state | status: errors}}
    end
  end

  @impl true
  def handle_call(:status, _from, %{status: status} = state) do
    {:reply, status, state}
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
    |> Enum.map(& &1)
  end
end
