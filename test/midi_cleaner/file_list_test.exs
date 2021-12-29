defmodule MidiCleaner.FileListTest do
  use ExUnit.Case
  doctest MidiCleaner.FileList

  alias MidiCleaner.FileList

  describe "each_file()" do
    test "list of midi files" do
      pid = self()

      ["1.mid", "2.mid"]
      |> FileList.new()
      |> FileList.each_file(&send(pid, &1))

      assert_received({"1.mid", "1.mid"})
      assert_received({"2.mid", "2.mid"})
    end

    test "dir" do
      pid = self()

      ["test/fixtures"]
      |> FileList.new()
      |> FileList.each_file(&send(pid, &1))

      assert_received({"test/fixtures/midi/drums.mid", "midi/drums.mid"})
      assert_received({"test/fixtures/midi/example.mid", "midi/example.mid"})
    end

    test "files and dirs mixed" do
      pid = self()

      ["1.mid", "2.mid", "test/fixtures"]
      |> FileList.new()
      |> FileList.each_file(&send(pid, &1))

      assert_received({"1.mid", "1.mid"})
      assert_received({"2.mid", "2.mid"})
      assert_received({"test/fixtures/midi/drums.mid", "midi/drums.mid"})
      assert_received({"test/fixtures/midi/example.mid", "midi/example.mid"})
    end
  end

  describe "each_dir()" do
    test "list of midi files" do
      pid = self()

      ["1.mid", "2.mid"]
      |> FileList.new()
      |> FileList.each_dir(&send(pid, &1))

      assert_received(".")
    end

    test "dir" do
      pid = self()

      ["test/fixtures"]
      |> FileList.new()
      |> FileList.each_dir(&send(pid, &1))

      assert_received("midi")
    end

    test "files and dirs mixed" do
      pid = self()

      ["1.mid", "files/2.mid", "test/fixtures"]
      |> FileList.new()
      |> FileList.each_dir(&send(pid, &1))

      assert_received(".")
      assert_received("files")
      assert_received("midi")
    end
  end
end
