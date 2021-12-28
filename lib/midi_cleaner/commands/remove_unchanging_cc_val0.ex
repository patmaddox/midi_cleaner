defmodule MidiCleaner.Commands.RemoveUnchangingCcVal0 do
  alias Midifile.{Event, Sequence, Track}

  def remove_unchanging_cc_val0(%Sequence{} = sequence) do
    %{sequence | tracks: remove_track_unchanging_cc_val0(sequence.tracks)}
  end

  defp remove_track_unchanging_cc_val0(tracks) when is_list(tracks),
    do: Enum.map(tracks, &remove_track_unchanging_cc_val0/1)

  defp remove_track_unchanging_cc_val0(%Track{} = track) do
    controls_to_keep = controls_to_keep(track.events)
    events = events_to_keep(track.events, controls_to_keep)
    %{track | events: events}
  end

  defp controls_to_keep(events) do
    events
    |> Stream.filter(&keep_control?/1)
    |> Stream.map(&cc/1)
    |> MapSet.new()
  end

  defp keep_control?(%Event{symbol: :controller, bytes: [_, _, val]}) when val > 0, do: true
  defp keep_control?(_), do: false

  defp events_to_keep(events, controls_to_keep),
    do: Enum.filter(events, &keep_event?(&1, controls_to_keep))

  defp keep_event?(%Event{symbol: :controller} = event, controls_to_keep),
    do: MapSet.member?(controls_to_keep, cc(event))

  defp keep_event?(_, _), do: true

  defp cc(%Event{bytes: [_, cc, _]}), do: cc
end
