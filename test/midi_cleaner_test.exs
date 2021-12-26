defmodule MidiCleanerTest do
  use ExUnit.Case
  doctest MidiCleaner

  alias Midifile.{Event, Sequence, Track}

  test "remove_program_changes(sequence)" do
    program_change = %Event{bytes: [192, 40], delta_time: 0, symbol: :program}
    note_on = %Event{bytes: [144, 72, 34], delta_time: 0, symbol: :on}
    track_with_pc = %Track{events: [program_change, note_on]}
    track_without_pc = %Track{events: [note_on]}

    conductor = %Track{
      events: [
        %Event{symbol: :seq_name, bytes: "Unnamed"},
        %Event{symbol: :tempo, bytes: [trunc(60_000_000 / 82)]}
      ]
    }

    sequence = %Sequence{
      division: 480,
      conductor_track: conductor,
      tracks: [track_with_pc, track_with_pc]
    }

    sequence_without_pc = %Sequence{
      division: 480,
      conductor_track: conductor,
      tracks: [track_without_pc, track_without_pc]
    }

    assert MidiCleaner.remove_program_changes(sequence) == sequence_without_pc
  end
end
