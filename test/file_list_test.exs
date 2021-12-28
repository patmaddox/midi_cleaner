defmodule MidiCleaner.FileListTest do
  use ExUnit.Case
  doctest MidiCleaner.FileList

  alias MidiCleaner.FileList

  describe "each_file()" do
    test "list of midi files" do
      FileList.new(["1.mid", "2.mid"])
      |> FileList.each_file(&send(self(), {:file, &1}))

      assert_received({:file, "1.mid"})
      assert_received({:file, "2.mid"})
    end

    test "dir" do
      FileList.new(["test/fixtures"])
      |> FileList.each_file(&send(self(), {:file, &1}))

      assert_received({:file, "test/fixtures/midi/drums.mid"})
      assert_received({:file, "test/fixtures/midi/example.mid"})
    end
  end

  describe "each_parent_dir()" do
    test "list of midi files" do
      FileList.new(["midi/drums/1.mid", "midi/bass/2.mid"])
      |> FileList.each_parent_dir(&send(self(), {:parent_dir, &1}))

      assert_received({:parent_dir, "midi/drums"})
      assert_received({:parent_dir, "midi/bass"})
    end

    test "dir" do
      FileList.new(["test/fixtures"])
      |> FileList.each_parent_dir(&send(self(), {:parent_dir, &1}))

      assert_received({:parent_dir, "test/fixtures/midi"})
    end

    test "files and dirs mixed" do
      FileList.new(["midi/drums/1.mid", "test/fixtures", "midi/2.mid", "test/fixtures/midi"])
      |> FileList.each_parent_dir(&send(self(), {:parent_dir, &1}))

      assert_received({:parent_dir, "midi/drums"})
      assert_received({:parent_dir, "midi"})
      assert_received({:parent_dir, "test/fixtures/midi"})
    end
  end
end
