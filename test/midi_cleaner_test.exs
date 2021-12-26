defmodule MidiCleanerTest do
  use ExUnit.Case
  doctest MidiCleaner

  alias Midifile.{Event, Sequence, Track}

  test "remove_program_changes(sequence)" do
    program_change = %Event{bytes: [192, 40], delta_time: 0, symbol: :program}
    note_on = %Event{bytes: [144, 72, 34], delta_time: 0, symbol: :on}

    track_with_pc = %Track{events: [program_change, note_on]}
    track_without_pc = %Track{events: [note_on]}

    sequence_with_pc = sequence(tracks: [track_with_pc, track_with_pc])

    sequence_without_pc = %Sequence{
      division: 480,
      conductor_track: conductor_track(),
      tracks: [track_without_pc, track_without_pc]
    }

    assert MidiCleaner.remove_program_changes(sequence_with_pc) == sequence_without_pc
  end

  test "set_midi_channel(sequence)" do
    text_event = %Event{bytes: "Violoncello", delta_time: 0, symbol: :seq_name}
    channel_0_controller = %Event{bytes: [176, 20, 0], delta_time: 0, symbol: :controller}
    channel_15_controller = %Event{bytes: [191, 20, 0], delta_time: 0, symbol: :controller}
    channel_0_note = %Event{bytes: [144, 74, 27], delta_time: 0, symbol: :on}
    channel_15_note = %Event{bytes: [159, 74, 27], delta_time: 0, symbol: :on}

    multi_channel_track = %Track{
      events: [
        text_event,
        channel_0_controller,
        channel_15_controller,
        channel_0_note,
        channel_15_note
      ]
    }

    single_channel_track = %Track{
      events: [
        text_event,
        channel_0_controller,
        channel_0_controller,
        channel_0_note,
        channel_0_note
      ]
    }

    multi_channel_sequence = sequence(tracks: [multi_channel_track, multi_channel_track])
    single_channel_sequence = sequence(tracks: [single_channel_track, single_channel_track])

    assert MidiCleaner.set_midi_channel(multi_channel_sequence) == single_channel_sequence
  end

  defp conductor_track() do
    %Track{
      events: [
        %Event{symbol: :seq_name, bytes: "Unnamed"},
        %Event{symbol: :tempo, bytes: [trunc(60_000_000 / 82)]}
      ]
    }
  end

  defp sequence(opts) do
    struct(
      %Sequence{
        division: 480,
        conductor_track: conductor_track(),
        tracks: []
      },
      opts
    )
  end
end
