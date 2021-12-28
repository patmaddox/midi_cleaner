defmodule MidiCleaner.FileProcessorTest do
  use ExUnit.Case
  doctest MidiCleaner.Runner

  import Mox

  alias MidiCleaner.{Config, FileProcessor, MockMidiCleaner}

  setup :verify_on_exit!

  describe "GenServer behavior" do
    test "status" do
      {:ok, pid} = FileProcessor.start_link([])
      :ok = FileProcessor.configure(pid, Config.new(), "in.mid", "out.mid")
      # {:ok, pid} = FileProcessor.new(Config.new(), "in.mid", "out.mid")
      assert FileProcessor.status(pid) == :new
    end
  end

  describe "process_file(config, infile, outfile)" do
    test "one command" do
      {:ok, pid} = FileProcessor.start_link([])

      :ok =
        FileProcessor.configure(
          pid,
          no_commands(remove_unchanging_cc_val0: true),
          "in.mid",
          "out.mid"
        )

      MockMidiCleaner
      |> expect_read_file("in.mid")
      |> expect_remove_unchanging_cc_val0("in.mid", :after_read_file)
      |> expect_write_file(
        "in.mid",
        :after_remove_unchanging_cc_val0,
        "export/clean/out.mid"
      )
      |> allow(self(), pid)

      FileProcessor.process(pid)
      FileProcessor.wait(pid)
    end

    test "a different command" do
      {:ok, pid} = FileProcessor.start_link([])

      :ok =
        FileProcessor.configure(
          pid,
          no_commands(remove_program_changes: true),
          "in.mid",
          "out.mid"
        )

      MockMidiCleaner
      |> expect_read_file("in.mid")
      |> expect_remove_program_changes("in.mid", :after_read_file)
      |> expect_write_file(
        "in.mid",
        :after_remove_program_changes,
        "export/clean/out.mid"
      )
      |> allow(self(), pid)

      FileProcessor.process(pid)
      FileProcessor.wait(pid)
    end

    test "all commands" do
      {:ok, pid} = FileProcessor.start_link([])
      :ok = FileProcessor.configure(pid, config(), "in.mid", "out.mid")

      MockMidiCleaner
      |> expect_read_file("in.mid")
      |> expect_remove_program_changes("in.mid", :after_read_file)
      |> expect_remove_unchanging_cc_val0("in.mid", :after_remove_program_changes)
      |> expect_set_midi_channel("in.mid", :after_remove_unchanging_cc_val0, 0)
      |> expect_write_file("in.mid", :after_set_midi_channel, "export/clean/out.mid")
      |> allow(self(), pid)

      FileProcessor.process(pid)
      FileProcessor.wait(pid)
    end
  end

  defp config(overrides \\ []) do
    %{
      file_list: ["example.mid", "files/example.mid", "example/midi"],
      output: "export/clean",
      remove_program_changes: true,
      remove_unchanging_cc_val0: true,
      set_midi_channel: 0
    }
    |> Map.merge(Map.new(overrides))
    |> Config.new()
  end

  defp no_commands(overrides) do
    [
      remove_program_changes: false,
      remove_unchanging_cc_val0: false,
      set_midi_channel: nil
    ]
    |> Keyword.merge(overrides)
    |> config()
  end

  defp expect_read_file(mock, filename) do
    expect(mock, :read_file, fn ^filename -> {filename, :after_read_file} end)
  end

  defp expect_remove_program_changes(mock, filename, sequence) do
    expect(mock, :remove_program_changes, fn {^filename, ^sequence} ->
      {filename, :after_remove_program_changes}
    end)
  end

  defp expect_remove_unchanging_cc_val0(mock, filename, sequence) do
    expect(mock, :remove_unchanging_cc_val0, fn {^filename, ^sequence} ->
      {filename, :after_remove_unchanging_cc_val0}
    end)
  end

  defp expect_set_midi_channel(mock, filename, sequence, channel) do
    expect(mock, :set_midi_channel, fn {^filename, ^sequence}, ^channel ->
      {filename, :after_set_midi_channel}
    end)
  end

  defp expect_write_file(mock, filename, sequence, outfile) do
    expect(mock, :write_file, fn {^filename, ^sequence}, ^outfile ->
      {filename, :after_write_file}
    end)
  end
end
