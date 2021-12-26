defmodule MidiCleaner do
  alias Midifile.{Event, Sequence, Track}

  defmodule Error do
    defexception message: "A MidiCleaner error has occurred."
  end

  def remove_program_changes(%Sequence{} = sequence) do
    %{sequence | tracks: remove_track_program_changes(sequence.tracks)}
  end

  def set_midi_channel(%Sequence{} = sequence, channel) when channel >= 0 and channel <= 15 do
    %{sequence | tracks: set_track_midi_channel(sequence.tracks, channel)}
  end

  def set_midi_channel(_sequence, channel) do
    raise Error, "Bad MIDI channel: #{channel}"
  end

  def remove_unchanging_cc_val0(%Sequence{} = sequence) do
    %{sequence | tracks: remove_track_unchanging_cc_val0(sequence.tracks)}
  end

  defp remove_track_program_changes(tracks) when is_list(tracks),
    do: Enum.map(tracks, &remove_track_program_changes/1)

  defp remove_track_program_changes(%Track{} = track) do
    %{track | events: remove_event_program_changes(track.events)}
  end

  defp remove_event_program_changes(events), do: Enum.reject(events, &event_is_program_change?/1)

  defp event_is_program_change?(%Event{symbol: :program}), do: true
  defp event_is_program_change?(%Event{}), do: false

  defp set_track_midi_channel(tracks, channel) when is_list(tracks),
    do: Enum.map(tracks, &set_track_midi_channel(&1, channel))

  defp set_track_midi_channel(%Track{} = track, channel) do
    %{track | events: set_event_midi_channel(track.events, channel)}
  end

  defp set_event_midi_channel(events, channel) when is_list(events),
    do: Enum.map(events, &set_event_midi_channel(&1, channel))

  defp set_event_midi_channel(%Event{} = event, new_channel) do
    if Event.channel?(event) do
      [first | rest] = event.bytes
      orig_channel = Event.channel(event)
      first = first - orig_channel + new_channel
      struct(event, bytes: [first | rest])
    else
      event
    end
  end

  defp remove_track_unchanging_cc_val0(tracks) when is_list(tracks),
    do: Enum.map(tracks, &remove_track_unchanging_cc_val0/1)

  defp remove_track_unchanging_cc_val0(%Track{} = track) do
    controls_to_keep =
      track.events
      |> Enum.filter(fn %Event{bytes: [_, _, val]} -> val > 0 end)
      |> Enum.map(fn %Event{bytes: [cc, _, _]} -> cc end)
      |> MapSet.new()

    events =
      track.events
      |> Enum.filter(fn %Event{bytes: [cc, _, _]} -> MapSet.member?(controls_to_keep, cc) end)

    %{track | events: events}
  end
end
