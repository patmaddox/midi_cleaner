defmodule MidiCleaner.CLITest do
  use ExUnit.Case
  doctest MidiCleaner.CLI

  import Mox

  alias MidiCleaner.{CLI, Config, FileList, MockRunner}
  alias MidiCleaner.Commands.{RemoveProgramChanges, RemoveUnchangingCcVal0, SetMidiChannel0}

  setup :verify_on_exit!

  test "no args" do
    MockRunner
    |> expect(:run, fn config ->
      assert config == %Config{
               file_list: FileList.new([]),
               output: nil,
               processors: []
             }
    end)

    CLI.main([])
  end

  test "file list" do
    MockRunner
    |> expect(:run, fn config ->
      assert config.file_list ==
               FileList.new(["example.mid", "midi/example.mid", "midi/examples"])
    end)

    CLI.main(["example.mid", "midi/example.mid", "midi/examples"])
  end

  test "--output=clean" do
    MockRunner
    |> expect(:run, fn config ->
      assert config.output == "clean"
    end)

    CLI.main(["--output=clean"])
  end

  test "--remove-program-changes" do
    MockRunner
    |> expect(:run, fn config ->
      assert config.processors == [RemoveProgramChanges]
    end)

    CLI.main(["--remove-program-changes"])
  end

  test "--remove-unchanging-cc-val0" do
    MockRunner
    |> expect(:run, fn config ->
      assert config.processors == [RemoveUnchangingCcVal0]
    end)

    CLI.main(["--remove-unchanging-cc-val0"])
  end

  test "--set-midi-channel=0" do
    MockRunner
    |> expect(:run, fn config ->
      assert config.processors == [SetMidiChannel0]
    end)

    CLI.main(["--set-midi-channel=0"])
  end

  test "all args" do
    MockRunner
    |> expect(:run, fn config ->
      assert config == %Config{
               file_list:
                 FileList.new([
                   "midi/example1.mid",
                   "orig/example2.mid",
                   "midi/examples"
                 ]),
               output: "clean",
               processors: [SetMidiChannel0, RemoveUnchangingCcVal0, RemoveProgramChanges]
             }
    end)

    CLI.main([
      "--output=clean",
      "--remove-program-changes",
      "--remove-unchanging-cc-val0",
      "--set-midi-channel=0",
      "midi/example1.mid",
      "orig/example2.mid",
      "midi/examples"
    ])
  end
end
