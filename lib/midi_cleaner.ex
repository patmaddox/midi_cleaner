defmodule MidiCleaner do
  @callback read_file(String.t()) :: :ok
  @callback write_file(Midifile.Sequence.t(), String.t()) :: :ok
  @callback make_dir(String.t()) :: :ok

  @callback remove_program_changes(Midifile.Sequence.t()) :: :ok
  @callback remove_unchanging_cc_val0(Midifile.Sequence.t()) :: :ok
  @callback set_midi_channel(Midifile.Sequence.t(), Integer.t()) :: :ok

  alias MidiCleaner.Commands.{RemoveProgramChanges, RemoveUnchangingCcVal0, SetMidiChannel}

  defmodule Error do
    defexception message: "A MidiCleaner error has occurred."
  end

  def remove_program_changes(sequence), do: RemoveProgramChanges.remove_program_changes(sequence)

  def remove_unchanging_cc_val0(sequence),
    do: RemoveUnchangingCcVal0.remove_unchanging_cc_val0(sequence)

  def set_midi_channel(sequence, channel), do: SetMidiChannel.set_midi_channel(sequence, channel)

  def read_file(filename), do: Midifile.read(filename)

  def write_file(sequence, filename), do: Midifile.write(sequence, filename)

  def make_dir(dir), do: File.mkdir_p!(dir)

  def midi_cleaner(), do: Application.get_env(:midi_cleaner, :midi_cleaner)

  def file_processor(), do: Application.get_env(:midi_cleaner, :file_processor)

  def runner(), do: Application.get_env(:midi_cleaner, :runner)
end
