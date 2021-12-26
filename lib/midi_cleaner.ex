defmodule MidiCleaner do
  alias Midifile.{Event, Sequence, Track}

  def remove_program_changes(%Sequence{} = sequence) do
    %{sequence | tracks: remove_track_program_changes(sequence.tracks)}
  end

  defp remove_track_program_changes(tracks) when is_list(tracks),
    do: Enum.map(tracks, &remove_track_program_changes/1)

  defp remove_track_program_changes(%Track{} = track) do
    %{track | events: remove_event_program_changes(track.events)}
  end

  defp remove_event_program_changes(events), do: Enum.reject(events, &event_is_program_change?/1)

  defp event_is_program_change?(%Event{symbol: :program}), do: true
  defp event_is_program_change?(%Event{}), do: false
end
