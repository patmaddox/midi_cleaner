Mox.defmock(MidiCleaner.MockRunner, for: MidiCleaner.Runner)
Application.put_env(:midi_cleaner, :runner, MidiCleaner.MockRunner)

ExUnit.start()
