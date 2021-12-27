defmodule MidiCleaner.CLITest do
  use ExUnit.Case
  doctest MidiCleaner.CLI

  import Mox

  alias MidiCleaner.{CLI, MockRunner}

  setup :verify_on_exit!

  test "no args" do
    MockRunner
    |> expect(:run, fn commands ->
      assert commands == []
    end)

    CLI.main([])
  end

  test "example.mid (file arg)" do
    MockRunner
    |> expect(:run, fn commands ->
      assert commands == [{&MidiCleaner.read_file/1, ["example.mid"]}]
    end)

    CLI.main(["example.mid"])
  end

  test "--o=clean.mid" do
    MockRunner
    |> expect(:run, fn commands ->
      assert commands == [{&MidiCleaner.write_file/2, ["clean.mid"]}]
    end)

    CLI.main(["--o=clean.mid"])
  end

  test "--pc" do
    MockRunner
    |> expect(:run, fn commands ->
      assert commands == [&MidiCleaner.remove_program_changes/1]
    end)

    CLI.main(["--pc"])
  end

  test "--cc0" do
    MockRunner
    |> expect(:run, fn commands ->
      assert commands == [&MidiCleaner.remove_unchanging_cc_val0/1]
    end)

    CLI.main(["--cc0"])
  end

  test "--ch=0" do
    MockRunner
    |> expect(:run, fn commands ->
      assert commands == [{&MidiCleaner.set_midi_channel/2, [0]}]
    end)

    CLI.main(["--ch=0"])
  end

  test "all args" do
    MockRunner
    |> expect(:run, fn commands ->
      assert commands == [
               {&MidiCleaner.read_file/1, ["example.mid"]},
               &MidiCleaner.remove_program_changes/1,
               &MidiCleaner.remove_unchanging_cc_val0/1,
               {&MidiCleaner.set_midi_channel/2, [1]},
               {&MidiCleaner.write_file/2, ["clean.mid"]}
             ]
    end)

    CLI.main(["--pc", "--cc0", "--ch=1", "--o=clean.mid", "example.mid"])
  end
end
