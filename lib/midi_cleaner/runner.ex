defmodule MidiCleaner.Runner do
  @callback run(Map.t()) :: :ok

  use GenServer

  import MidiCleaner, only: [midi_cleaner: 0]

  alias MidiCleaner.{Config, FileList}

  def new(config) do
    state = %{
      config: config,
      processors: MapSet.new(),
      status: :new
    }

    GenServer.start_link(__MODULE__, state)
  end

  def run(%Config{} = config) do
    {:ok, pid} = new(config)
    run(pid)
    wait(pid)
  end

  def run(pid), do: GenServer.call(pid, :run)

  def wait(pid), do: GenServer.call(pid, :wait)

  def status(pid), do: GenServer.call(pid, :status)

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call(:run, _from, %{config: config, processors: processors} = state) do
    with :ok <- Config.validate(config) do
      FileList.dirs(config.file_list) |> Enum.each(&make_output_dir(&1, config))

      new_processors =
        FileList.files(config.file_list)
        |> Enum.map(fn {infile, outfile} ->
          {:ok, processor} = file_processor().process_file(config, infile, outfile)
          processor
        end)
        |> MapSet.new()
        |> MapSet.union(processors)

      {:reply, :ok, %{state | status: :running, processors: new_processors}}
    else
      errors -> {:reply, errors, %{state | status: errors}}
    end
  end

  @impl true
  def handle_call(:wait, _from, %{processors: processors, status: status} = state) do
    case status do
      {:error, _} ->
        {:reply, status, state}

      :running ->
        Enum.each(processors, &file_processor().wait(&1))
        {:reply, :ok, %{state | status: :ok, processors: MapSet.new()}}
    end
  end

  @impl true
  def handle_call(:status, _from, %{status: status} = state) do
    {:reply, status, state}
  end

  defp make_output_dir(dir, config) do
    output_dir = Path.join(config.output, dir)
    midi_cleaner().make_dir(output_dir)
  end

  defp file_processor(), do: Application.get_env(:midi_cleaner, :file_processor)
end
