defmodule MidiCleaner do
  alias MidiCleaner.{RemoveProgramChanges, RemoveUnchangingCcVal0, SetMidiChannel}

  defmodule Error do
    defexception message: "A MidiCleaner error has occurred."
  end

  def remove_program_changes(sequence), do: RemoveProgramChanges.remove_program_changes(sequence)

  def remove_unchanging_cc_val0(sequence),
    do: RemoveUnchangingCcVal0.remove_unchanging_cc_val0(sequence)

  def set_midi_channel(sequence, channel), do: SetMidiChannel.set_midi_channel(sequence, channel)

  def read_file(filename), do: Midifile.read(filename)

  def write_file(sequence, filename), do: Midifile.write(sequence, filename)
end
