defmodule MidiCleaner.FileListTest do
  use ExUnit.Case
  doctest MidiCleaner.FileList

  alias MidiCleaner.FileList

  describe "files()" do
    test "list of midi files" do
      files = FileList.new(["1.mid", "2.mid"]) |> FileList.files() |> Enum.map(& &1)

      assert files == [
               {"1.mid", "1.mid"},
               {"2.mid", "2.mid"}
             ]
    end

    test "dir" do
      files = FileList.new(["test/fixtures"]) |> FileList.files() |> Enum.map(& &1)

      assert files == [
               {"test/fixtures/midi/drums.mid", "midi/drums.mid"},
               {"test/fixtures/midi/example.mid", "midi/example.mid"}
             ]
    end

    test "files and dirs mixed" do
      files = FileList.new(["1.mid", "2.mid", "test/fixtures"]) |> FileList.files() |> Enum.map(& &1)

      assert files == [
               {"1.mid", "1.mid"},
               {"2.mid", "2.mid"},
               {"test/fixtures/midi/drums.mid", "midi/drums.mid"},
               {"test/fixtures/midi/example.mid", "midi/example.mid"}
             ]
    end
  end

  describe "dirs()" do
    test "list of midi files" do
      dirs = FileList.new(["midi/drums/1.mid", "midi/bass/2.mid"]) |> FileList.dirs()

      assert dirs ==
               MapSet.new([
                 "midi/bass",
                 "midi/drums"
               ])
    end

    test "dir" do
      dirs = FileList.new(["test/fixtures"]) |> FileList.dirs()
      assert dirs == MapSet.new(["midi"])
    end

    test "files and dirs mixed" do
      dirs =
        FileList.new(["files/drums/1.mid", "test/fixtures", "files/2.mid", "test/fixtures/midi"])
        |> FileList.dirs()

      assert dirs ==
               MapSet.new([
                 ".",
                 "files",
                 "files/drums",
                 "midi"
               ])
    end
  end
end
