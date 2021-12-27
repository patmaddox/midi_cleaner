defmodule MidiCleaner.CLITest do
  use ExUnit.Case
  doctest MidiCleaner.CLI

  import Mox

  alias MidiCleaner.{CLI, MockRunner}

  setup :verify_on_exit!

  test "no args" do
    assert CLI.main([]) == nil
  end

  test "example.mid (file arg)" do
    MockRunner
    |> expect(:run, fn commands ->
      assert commands == [[{&MidiCleaner.read_file/1, ["example.mid"]}]]
    end)

    CLI.main(["example.mid"])
  end

  test "input folder" do
    MockRunner
    |> expect(:run, fn commands ->
      assert commands == [
               [{&MidiCleaner.read_file/1, ["test/fixtures/midi/drums.mid"]}],
               [{&MidiCleaner.read_file/1, ["test/fixtures/midi/example.mid"]}]
             ]
    end)

    CLI.main(["test/fixtures"])
  end

  test "multiple files" do
    MockRunner
    |> expect(:run, fn commands ->
      assert commands == [
               [{&MidiCleaner.read_file/1, ["example1.mid"]}],
               [{&MidiCleaner.read_file/1, ["example2.mid"]}]
             ]
    end)

    CLI.main(["example1.mid", "example2.mid"])
  end

  test "all args" do
    MockRunner
    |> expect(:run, fn commands ->
      assert commands == [
               [{&File.mkdir_p!/1, ["clean/midi"]}],
               [
                 {&MidiCleaner.read_file/1, ["midi/example.mid"]},
                 &MidiCleaner.remove_program_changes/1,
                 &MidiCleaner.remove_unchanging_cc_val0/1,
                 {&MidiCleaner.set_midi_channel/2, [1]},
                 {&MidiCleaner.write_file/2, ["clean/midi/example.mid"]}
               ]
             ]
    end)

    CLI.main(["--pc", "--cc0", "--ch=1", "--o=clean", "midi/example.mid"])
  end

  test "all args (multiple files)" do
    MockRunner
    |> expect(:run, fn commands ->
      assert commands == [
               [{&File.mkdir_p!/1, ["clean/midi"]}],
               [
                 {&MidiCleaner.read_file/1, ["midi/example1.mid"]},
                 &MidiCleaner.remove_program_changes/1,
                 &MidiCleaner.remove_unchanging_cc_val0/1,
                 {&MidiCleaner.set_midi_channel/2, [1]},
                 {&MidiCleaner.write_file/2, ["clean/midi/example1.mid"]}
               ],
               [{&File.mkdir_p!/1, ["clean/orig"]}],
               [
                 {&MidiCleaner.read_file/1, ["orig/example2.mid"]},
                 &MidiCleaner.remove_program_changes/1,
                 &MidiCleaner.remove_unchanging_cc_val0/1,
                 {&MidiCleaner.set_midi_channel/2, [1]},
                 {&MidiCleaner.write_file/2, ["clean/orig/example2.mid"]}
               ]
             ]
    end)

    CLI.main(["--pc", "--cc0", "--ch=1", "--o=clean", "midi/example1.mid", "orig/example2.mid"])
  end

  test "all args (target dir)" do
    MockRunner
    |> expect(:run, fn commands ->
      assert commands == [
               [{&File.mkdir_p!/1, ["clean/midi"]}],
               [
                 {&MidiCleaner.read_file/1, ["test/fixtures/midi/drums.mid"]},
                 &MidiCleaner.remove_program_changes/1,
                 &MidiCleaner.remove_unchanging_cc_val0/1,
                 {&MidiCleaner.set_midi_channel/2, [1]},
                 {&MidiCleaner.write_file/2, ["clean/midi/drums.mid"]}
               ],
               [{&File.mkdir_p!/1, ["clean/midi"]}],
               [
                 {&MidiCleaner.read_file/1, ["test/fixtures/midi/example.mid"]},
                 &MidiCleaner.remove_program_changes/1,
                 &MidiCleaner.remove_unchanging_cc_val0/1,
                 {&MidiCleaner.set_midi_channel/2, [1]},
                 {&MidiCleaner.write_file/2, ["clean/midi/example.mid"]}
               ]
             ]
    end)

    CLI.main(["--pc", "--cc0", "--ch=1", "--o=clean", "test/fixtures/midi"])
  end
end
