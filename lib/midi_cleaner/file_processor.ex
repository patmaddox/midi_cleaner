defmodule MidiCleaner.FileProcessor do
  @callback process_file(MidiCleaner.Config.t(), String.t(), String.t()) :: :ok

  use GenServer

  import MidiCleaner, only: [midi_cleaner: 0]

  alias MidiCleaner.Config

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def configure(pid, %Config{} = config, infile, outfile) do
    state = %{
      config: config,
      infile: infile,
      outfile: outfile
    }

    GenServer.call(pid, {:configure, state})
  end

  def process_file(config, infile, outfile) do
    {:ok, pid} = start_link([])
    :ok = configure(pid, config, infile, outfile)
    :ok = process(pid)
    :ok = GenServer.stop(pid)
  end

  def process(pid), do: GenServer.call(pid, :process)

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:configure, new_state}, _from, _state), do: {:reply, :ok, new_state}

  @impl true
  def handle_call(:process, _from, %{config: config, infile: infile, outfile: outfile} = state) do
    read_file(infile)
    |> process(config)
    |> write_file(outfile, config)

    {:reply, :ok, state}
  end

  defp read_file(filename) do
    record_time(:read_file, fn -> midi_cleaner().read_file(filename) end)
  end

  defp process(sequence, %{processors: processors}) do
    record_time(:process, fn -> midi_cleaner().process(sequence, processors) end)
  end

  defp write_file(sequence, filename, config) do
    record_time(:write_file, fn ->
      filename = Enum.join([config.output, filename], "/")
      midi_cleaner().write_file(sequence, filename)
    end)
  end

  defp record_time(event, func) do
    MidiCleaner.record_time([:file_processor, event], func)
  end
end
