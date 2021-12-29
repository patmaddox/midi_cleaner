defmodule MidiCleanerTest do
  use ExUnit.Case
  doctest MidiCleaner

  alias MidiCleaner.Commands.{RemoveProgramChanges, RemoveUnchangingCcVal0, SetMidiChannel}
  alias Midifile.{Event, Sequence, Track}

  describe "process(sequence)" do
    test "RemoveProgramChanges" do
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

      processed_sequence = MidiCleaner.process(sequence_with_pc, RemoveProgramChanges)
      assert processed_sequence == sequence_without_pc
    end

    test "RemoveUnchangingCcVal0" do
      cc_val0 = event(bytes: [176, 20, 0], symbol: :controller)
      cc_val1 = event(bytes: [177, 20, 1], symbol: :controller)

      note_on = event(bytes: [144, 20, 26], symbol: :on)
      note_off = event(bytes: [128, 20, 0], symbol: :off)
      text_event = event(bytes: "Violoncello", symbol: :seq_name)

      unchanging_track = %Track{
        events: [cc_val0, cc_val0, cc_val0, note_on, note_off, text_event]
      }

      changing_track = %Track{events: [cc_val0, cc_val1, cc_val0, note_on, note_off, text_event]}
      track_with_no_cc = %Track{events: [note_on, note_off, text_event]}

      orig_sequence = sequence(tracks: [unchanging_track, changing_track])
      clean_sequence = sequence(tracks: [track_with_no_cc, changing_track])

      processed_sequence = MidiCleaner.process(orig_sequence, RemoveUnchangingCcVal0)
      assert processed_sequence == clean_sequence
    end

    test "SetMidiChannel(channel)" do
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

      channel_0_processor = SetMidiChannel.make_processor(0)

      assert MidiCleaner.process(multi_channel_sequence, channel_0_processor) ==
               channel_0_sequence

      channel_15_processor = SetMidiChannel.make_processor(15)

      assert MidiCleaner.process(multi_channel_sequence, channel_15_processor) ==
               channel_15_sequence
    end

    test "multiple processors" do
      program_change = event(bytes: [192, 40], symbol: :program)
      cc_val0 = event(bytes: [176, 20, 0], symbol: :controller)
      note_on = event(bytes: [144, 20, 26], symbol: :on)

      orig_track = %Track{events: [program_change, note_on, cc_val0]}
      clean_track = %Track{events: [note_on]}

      orig_sequence = sequence(tracks: [orig_track, orig_track])

      clean_sequence = %Sequence{
        division: 480,
        conductor_track: conductor_track(),
        tracks: [clean_track, clean_track]
      }

      processed_sequence =
        MidiCleaner.process(orig_sequence, [RemoveProgramChanges, RemoveUnchangingCcVal0])

      assert processed_sequence == clean_sequence
    end
  end

  describe "SetMidiChannel.make_processor" do
    test "channel out of range" do
      assert_raise MidiCleaner.Error, ~r/Bad MIDI channel: -1/, fn ->
        SetMidiChannel.make_processor(-1)
      end

      assert_raise MidiCleaner.Error, ~r/Bad MIDI channel: 16/, fn ->
        SetMidiChannel.make_processor(16)
      end
    end
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
