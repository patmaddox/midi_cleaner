defmodule MidiCleaner do
  @callback read_file(String.t()) :: :ok
  @callback write_file(Midifile.Sequence.t(), String.t()) :: :ok
  @callback make_dir(String.t()) :: :ok
  @callback process(MidiFile.Sequence.t(), List.t()) :: :ok

  defmodule Error do
    defexception message: "A MidiCleaner error has occurred."
  end

  def read_file(filename), do: Midifile.read(filename)

  def write_file(sequence, filename), do: Midifile.write(sequence, filename)

  def make_dir(dir), do: File.mkdir_p!(dir)

  def midi_cleaner(), do: Application.get_env(:midi_cleaner, :midi_cleaner)

  def file_processor(), do: Application.get_env(:midi_cleaner, :file_processor)

  def runner(), do: Application.get_env(:midi_cleaner, :runner)

  def process(sequence, processor) when not is_list(processor) do
    process(sequence, [processor])
  end

  def process(%{tracks: tracks} = sequence, processors) do
    tracks = Enum.map(tracks, &process_track(&1, processors))
    %{sequence | tracks: tracks}
  end

  defp process_track(%{events: events} = track, processors) do
    processors = Enum.map(processors, &{&1, &1.preview_events(events)})

    events =
      Enum.map(events, &process_event(&1, processors))
      |> Enum.reject(&(&1 == :drop))

    %{track | events: events}
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
