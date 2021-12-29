defmodule MidiCleaner do
  @callback read_file(String.t()) :: :ok
  @callback write_file(Midifile.Sequence.t(), String.t()) :: :ok
  @callback make_dir(String.t()) :: :ok
  @callback process(MidiFile.Sequence.t(), List.t()) :: :ok

  alias MidiCleaner.DirTree

  defmodule Error do
    defexception message: "A MidiCleaner error has occurred."
  end

  def read_file(filename), do: Midifile.read(filename)

  def write_file(sequence, filename), do: Midifile.write(sequence, filename)

  def make_dir(dir), do: DirTree.mkdir_p(dir)

  def midi_cleaner(), do: Application.get_env(:midi_cleaner, :midi_cleaner)

  def file_processor(), do: Application.get_env(:midi_cleaner, :file_processor)

  def runner(), do: Application.get_env(:midi_cleaner, :runner)

  def process(sequence, processor) when not is_list(processor) do
    process(sequence, [processor])
  end

  def process(%{tracks: tracks} = sequence, processors) do
    tracks =
      tracks
      |> Enum.map(&process_track(&1, processors))

    %{sequence | tracks: tracks}
  end

  defp process_track(%{events: events} = track, processors) do
    {preview_processors, simple_processors} =
      Enum.split_with(processors, fn processor ->
        Code.ensure_loaded(processor)
        Kernel.function_exported?(processor, :preview_event, 2)
      end)

    preview_processors = preview_events(events, preview_processors, %{})
    simple_processors = Enum.map(simple_processors, &{&1, []})
    processors = Enum.concat(preview_processors, simple_processors)

    events =
      events
      |> Stream.map(&process_event(&1, processors))
      |> Stream.reject(&(&1 == :drop))
      |> Enum.map(& &1)

    %{track | events: events}
  end

  defp preview_events([], _, processor_args), do: processor_args |> Map.to_list()

  defp preview_events([event | rest], processors, processor_args) do
    new_processor_args = preview_event(event, processors, processor_args)
    preview_events(rest, processors, new_processor_args)
  end

  defp preview_event(_event, [], processor_args), do: processor_args

  defp preview_event(event, [processor | rest], processor_args) do
    current_args = processor_args[processor] || :preview_event
    args = apply(processor, :preview_event, [event, current_args])
    new_processor_args = Map.put(processor_args, processor, args)
    preview_event(event, rest, new_processor_args)
  end

  defp process_event(:drop, _), do: :drop
  defp process_event(event, []), do: event

  defp process_event(event, [{processor, args} | rest]) do
    apply(processor, :process_event, [event | args])
    |> process_event(rest)
  end
end
