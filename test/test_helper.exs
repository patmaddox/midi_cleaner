Mox.defmock(MidiCleaner.MockMidiCleaner, for: MidiCleaner)
Application.put_env(:midi_cleaner, :midi_cleaner, MidiCleaner.MockMidiCleaner)

Mox.defmock(MidiCleaner.MockRunner, for: MidiCleaner.Runner)
Application.put_env(:midi_cleaner, :runner, MidiCleaner.MockRunner)

ExUnit.start()
