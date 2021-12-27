defmodule MidiCleaner.Config do
  defstruct file_list: [],
            output: nil,
            remove_program_changes: false,
            remove_unchanging_cc_val0: false,
            set_midi_channel: nil
end
