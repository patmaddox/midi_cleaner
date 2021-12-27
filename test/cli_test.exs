defmodule MidiCleaner.CLITest do
  use ExUnit.Case
  doctest MidiCleaner.CLI

  import Mox

  alias MidiCleaner.{CLI, MockRunner}

  setup :verify_on_exit!

  test "no args" do
    MockRunner
    |> expect(:run, fn config ->
      assert config == %{
               file_list: [],
               output: nil,
               remove_program_changes: false,
               remove_unchanging_cc_val0: false,
               set_midi_channel: nil
             }
    end)

    CLI.main([])
  end

  test "file list" do
    MockRunner
    |> expect(:run, fn config ->
      assert config.file_list == ["example.mid", "midi/example.mid", "midi/examples"]
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
      assert config.remove_program_changes
    end)

    CLI.main(["--remove-program-changes"])
  end

  test "--remove-unchanging-cc-val0" do
    MockRunner
    |> expect(:run, fn config ->
      assert config.remove_unchanging_cc_val0
    end)

    CLI.main(["--remove-unchanging-cc-val0"])
  end

  test "--set-midi-channel=0" do
    MockRunner
    |> expect(:run, fn config ->
      assert config.set_midi_channel == 0
    end)

    CLI.main(["--set-midi-channel=0"])
  end

  test "all args" do
    MockRunner
    |> expect(:run, fn config ->
      assert config == %{
               file_list: [
                 "midi/example1.mid",
                 "orig/example2.mid",
                 "midi/examples"
               ],
               output: "clean",
               remove_program_changes: true,
               remove_unchanging_cc_val0: true,
               set_midi_channel: 0
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
