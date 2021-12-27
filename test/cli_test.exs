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
      assert commands == [{&MidiCleaner.set_midi_channel/2, 0}]
    end)

    CLI.main(["--ch=0"])
  end

  test "all args" do
    MockRunner
    |> expect(:run, fn commands ->
      assert commands == [
               &MidiCleaner.remove_program_changes/1,
               &MidiCleaner.remove_unchanging_cc_val0/1,
               {&MidiCleaner.set_midi_channel/2, 1}
             ]
    end)

    CLI.main(["--pc", "--cc0", "--ch=1"])
  end
end
