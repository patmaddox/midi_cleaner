defmodule MidiCleaner.FileListTest do
  use ExUnit.Case
  doctest MidiCleaner.FileList

  alias MidiCleaner.FileList

  describe "each_file()" do
    test "list of midi files" do
      ["1.mid", "2.mid"]
      |> FileList.new()
      |> FileList.each_file(&send(self(), &1))

      assert_received({"1.mid", "1.mid"})
      assert_received({"2.mid", "2.mid"})
    end

    test "dir" do
      ["test/fixtures"]
      |> FileList.new()
      |> FileList.each_file(&send(self(), &1))

      assert_received({"test/fixtures/midi/drums.mid", "midi/drums.mid"})
      assert_received({"test/fixtures/midi/example.mid", "midi/example.mid"})
    end

    test "files and dirs mixed" do
      ["1.mid", "2.mid", "test/fixtures"]
      |> FileList.new()
      |> FileList.each_file(&send(self(), &1))

      assert_received({"1.mid", "1.mid"})
      assert_received({"2.mid", "2.mid"})
      assert_received({"test/fixtures/midi/drums.mid", "midi/drums.mid"})
      assert_received({"test/fixtures/midi/example.mid", "midi/example.mid"})
    end
  end
end
