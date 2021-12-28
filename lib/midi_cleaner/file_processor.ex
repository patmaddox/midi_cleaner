defmodule MidiCleaner.FileProcessor do
  @callback process_file(MidiCleaner.Config.t(), String.t(), String.t()) :: :ok

  use GenServer

  import MidiCleaner, only: [midi_cleaner: 0]

  def process_file(config, infile, outfile) do
    {:ok, pid} = new(config, infile, outfile)
    {process(pid), pid}
  end

  def new(config, infile, outfile) do
    state = %{
      config: config,
      infile: infile,
      outfile: outfile,
      status: :new
    }

    GenServer.start_link(__MODULE__, state)
  end

  def process(pid), do: GenServer.cast(pid, :process)

  def status(pid), do: GenServer.call(pid, :status)

  def wait(pid, interval \\ 100) do
    if status(pid) == :done do
      :ok
    else
      :timer.sleep(interval)
      wait(pid, interval)
    end
  end

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call(:status, _from, state), do: {:reply, state.status, state}

  @impl true
  def handle_cast(:process, %{config: config, infile: infile, outfile: outfile} = state) do
    read_file(infile)
    |> maybe_remove_program_changes(config)
    |> maybe_remove_unchanging_cc_val0(config)
    |> maybe_set_midi_channel(config)
    |> write_file(outfile, config)

    {:noreply, %{state | status: :done}}
  end

  defp read_file(filename), do: midi_cleaner().read_file(filename)

  defp write_file(sequence, filename, config) do
    filename = Enum.join([config.output, filename], "/")
    midi_cleaner().write_file(sequence, filename)
  end

  defp maybe_remove_program_changes(sequence, %{remove_program_changes: true}),
    do: midi_cleaner().remove_program_changes(sequence)

  defp maybe_remove_program_changes(sequence, _config), do: sequence

  defp maybe_remove_unchanging_cc_val0(sequence, %{remove_unchanging_cc_val0: true}),
    do: midi_cleaner().remove_unchanging_cc_val0(sequence)

  defp maybe_remove_unchanging_cc_val0(sequence, _config), do: sequence

  defp maybe_set_midi_channel(sequence, %{set_midi_channel: ch}) when is_integer(ch),
    do: midi_cleaner().set_midi_channel(sequence, ch)

  defp maybe_set_midi_channel(sequence, _config), do: sequence
end
