defmodule MidiCleaner.FileListTest do
  use ExUnit.Case
  doctest MidiCleaner.FileList

  alias MidiCleaner.FileList

  describe "each_file()" do
    test "list of midi files" do
      FileList.new(["1.mid", "2.mid"])
      |> FileList.each_file(&send(self(), {:file, &1}))

      assert_received({:file, {"1.mid", "1.mid"}})
      assert_received({:file, {"2.mid", "2.mid"}})
    end

    test "dir" do
      FileList.new(["test/fixtures"])
      |> FileList.each_file(&send(self(), {:file, &1}))

      assert_received({:file, {"test/fixtures/midi/drums.mid", "midi/drums.mid"}})
      assert_received({:file, {"test/fixtures/midi/example.mid", "midi/example.mid"}})
    end
  end

  describe "each_dir()" do
    test "list of midi files" do
      FileList.new(["midi/drums/1.mid", "midi/bass/2.mid"])
      |> FileList.each_dir(&send(self(), {:dir, &1}))

      assert_received({:dir, "midi/drums"})
      assert_received({:dir, "midi/bass"})
    end

    test "dir" do
      FileList.new(["test/fixtures"])
      |> FileList.each_dir(&send(self(), {:dir, &1}))

      assert_received({:dir, "midi"})
    end

    test "files and dirs mixed" do
      FileList.new(["files/drums/1.mid", "test/fixtures", "files/2.mid", "test/fixtures/midi"])
      |> FileList.each_dir(&send(self(), {:dir, &1}))

      assert_received({:dir, "files/drums"})
      assert_received({:dir, "files"})
      assert_received({:dir, "midi"})
    end
  end
end
