defmodule MidiCleaner.Commands.SetMidiChannel do
  alias MidiCleaner.Error
  alias Midifile.{Event, Sequence, Track}

  def set_midi_channel(%Sequence{} = sequence, channel) when channel >= 0 and channel <= 15 do
    %{sequence | tracks: set_track_midi_channel(sequence.tracks, channel)}
  end

  def set_midi_channel(_sequence, channel) do
    raise Error, "Bad MIDI channel: #{channel}"
  end

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
end
