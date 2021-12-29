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

  def record_time(event, func) do
    :telemetry.span(
      [:midi_cleaner | event],
      %{},
      fn ->
        {func.(), %{}}
      end
    )
  end

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

    preview_processors = preview_events(events, preview_processors)
    simple_processors = Enum.map(simple_processors, &{&1, []})
    processors = Enum.concat(preview_processors, simple_processors)

    events =
      events
      |> Stream.map(&process_event(&1, processors))
      |> Stream.reject(&(&1 == :drop))
      |> Enum.map(& &1)

    %{track | events: events}
  end

  defp preview_events(events, processors) do
    Enum.reduce(events, %{}, fn event, processor_args ->
      preview_event(event, processors, processor_args)
    end)
    |> Map.to_list()
  end

  defp preview_event(event, processors, processor_args) do
    Enum.reduce(processors, processor_args, fn processor, processor_args ->
      current_args = processor_args[processor] || :preview_event
      args = apply(processor, :preview_event, [event, current_args])
      Map.put(processor_args, processor, args)
    end)
  end

  defp process_event(event, processors) do
    Enum.reduce(processors, event, fn {processor, args}, e ->
      if e == :drop do
        :drop
      else
        apply(processor, :process_event, [e | args])
      end
    end)
  end
end
