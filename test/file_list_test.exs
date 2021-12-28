defmodule MidiCleaner.FileListTest do
  use ExUnit.Case
  doctest MidiCleaner.FileList

  alias MidiCleaner.FileList

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
