defmodule MidiCleanerTest do
  use ExUnit.Case
  doctest MidiCleaner

  alias Midifile.{Event, Sequence, Track}

  test "remove_program_changes(sequence)" do
    program_change = event(bytes: [192, 40], symbol: :program)
    note_on = event(bytes: [144, 72, 34], symbol: :on)

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

  test "set_midi_channel(sequence, channel)" do
    text_event = event(bytes: "Violoncello", symbol: :seq_name)
    channel_0_controller = event(bytes: [176, 20, 0], symbol: :controller)
    channel_15_controller = event(bytes: [191, 20, 0], symbol: :controller)
    channel_0_note = event(bytes: [144, 74, 27], symbol: :on)
    channel_15_note = event(bytes: [159, 74, 27], symbol: :on)

    multi_channel_track = %Track{
      events: [
        text_event,
        channel_0_controller,
        channel_15_controller,
        channel_0_note,
        channel_15_note
      ]
    }

    channel_0_track = %Track{
      events: [
        text_event,
        channel_0_controller,
        channel_0_controller,
        channel_0_note,
        channel_0_note
      ]
    }

    channel_15_track = %Track{
      events: [
        text_event,
        channel_15_controller,
        channel_15_controller,
        channel_15_note,
        channel_15_note
      ]
    }

    multi_channel_sequence = sequence(tracks: [multi_channel_track, multi_channel_track])
    channel_0_sequence = sequence(tracks: [channel_0_track, channel_0_track])
    channel_15_sequence = sequence(tracks: [channel_15_track, channel_15_track])

    assert MidiCleaner.set_midi_channel(multi_channel_sequence, 0) == channel_0_sequence
    assert MidiCleaner.set_midi_channel(multi_channel_sequence, 15) == channel_15_sequence

    assert_raise MidiCleaner.Error, ~r/Bad MIDI channel: -1/, fn ->
      MidiCleaner.set_midi_channel(multi_channel_sequence, -1)
    end

    assert_raise MidiCleaner.Error, ~r/Bad MIDI channel: 16/, fn ->
      MidiCleaner.set_midi_channel(multi_channel_sequence, 16)
    end
  end

  test "remove_unchanging_cc_val0(sequence)" do
    cc_val0 = event(bytes: [176, 20, 0], symbol: :controller)
    cc_val1 = event(bytes: [176, 20, 1], symbol: :controller)

    unchanging_track = %Track{events: [cc_val0, cc_val0, cc_val0]}
    changing_track = %Track{events: [cc_val0, cc_val1, cc_val0]}
    empty_track = %Track{events: []}

    orig_sequence = sequence(tracks: [unchanging_track, changing_track])
    clean_sequence = sequence(tracks: [empty_track, changing_track])

    assert MidiCleaner.remove_unchanging_cc_val0(orig_sequence) == clean_sequence
  end

  defp conductor_track() do
    %Track{
      events: [
        event(symbol: :seq_name, bytes: "Unnamed"),
        event(symbol: :tempo, bytes: [trunc(60_000_000 / 82)])
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

  defp event(opts) do
    struct(
      %Event{delta_time: 0},
      opts
    )
  end
end
