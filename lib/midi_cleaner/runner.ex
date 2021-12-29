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
      process_files(config)
      {:reply, :ok, config}
    else
      errors -> {:reply, errors, config}
    end
  end

  defp process_files(%{file_list: file_list, output: output} = config) do
    FileList.each_file(file_list, fn {infile, outfile} ->
      make_output_dir(outfile, output)
      :ok = file_processor().process_file(config, infile, outfile)
    end)
  end

  defp make_output_dir(file, output) do
    parent_dir =
      Path.dirname(file)
      |> Path.relative_to(output)

    Path.join(output, parent_dir)
    |> midi_cleaner().make_dir()
  end
end
