defmodule MidiCleaner.RunnerTest do
  use ExUnit.Case
  doctest MidiCleaner.Runner

  import Mox

  alias MidiCleaner.{Config, Runner, MockMidiCleaner}

  setup :verify_on_exit!

  describe "run(config)" do
    test "errors" do
      config = config(file_list: [])
      assert {:error, _} = Runner.run(config)
    end

    test "one file, one command" do
      MockMidiCleaner
      |> expect_make_dir("export/clean/.")
      |> expect_read_file("example.mid")
      |> expect_remove_unchanging_cc_val0("example.mid", :after_read_file)
      |> expect_write_file(
        "example.mid",
        :after_remove_unchanging_cc_val0,
        "export/clean/example.mid"
      )

      config =
        no_commands(
          file_list: ["example.mid"],
          remove_unchanging_cc_val0: true
        )

      assert :ok == Runner.run(config)
    end

    test "one file, different command" do
      MockMidiCleaner
      |> expect_make_dir("export/clean/midi")
      |> expect_read_file("midi/example.mid")
      |> expect_remove_program_changes("midi/example.mid", :after_read_file)
      |> expect_write_file(
        "midi/example.mid",
        :after_remove_program_changes,
        "export/clean/midi/example.mid"
      )

      config =
        no_commands(
          file_list: ["midi/example.mid"],
          remove_program_changes: true
        )

      assert :ok == Runner.run(config)
    end

    test "one file, all commands" do
      MockMidiCleaner
      |> expect_make_dir("export/clean/.")
      |> expect_read_file("example.mid")
      |> expect_remove_program_changes("example.mid", :after_read_file)
      |> expect_remove_unchanging_cc_val0("example.mid", :after_remove_program_changes)
      |> expect_set_midi_channel("example.mid", :after_remove_unchanging_cc_val0, 0)
      |> expect_write_file("example.mid", :after_set_midi_channel, "export/clean/example.mid")

      config = config(file_list: ["example.mid"])
      assert :ok == Runner.run(config)
    end

    test "multiple files" do
      MockMidiCleaner
      |> expect_make_dir("export/clean/bass")
      |> expect_make_dir("export/clean/drums")
      |> expect_read_file("drums/1.mid")
      |> expect_remove_program_changes("drums/1.mid", :after_read_file)
      |> expect_remove_unchanging_cc_val0("drums/1.mid", :after_remove_program_changes)
      |> expect_set_midi_channel("drums/1.mid", :after_remove_unchanging_cc_val0, 0)
      |> expect_write_file("drums/1.mid", :after_set_midi_channel, "export/clean/drums/1.mid")
      |> expect_read_file("bass/2.mid")
      |> expect_remove_program_changes("bass/2.mid", :after_read_file)
      |> expect_remove_unchanging_cc_val0("bass/2.mid", :after_remove_program_changes)
      |> expect_set_midi_channel("bass/2.mid", :after_remove_unchanging_cc_val0, 0)
      |> expect_write_file("bass/2.mid", :after_set_midi_channel, "export/clean/bass/2.mid")

      config = config(file_list: ["drums/1.mid", "bass/2.mid"])
      assert :ok == Runner.run(config)
    end
  end

  defp config(overrides) do
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

  defp expect_make_dir(mock, dir),
    do: expect(mock, :make_dir, fn ^dir -> {dir, :after_make_dir} end)

  defp expect_read_file(mock, filename),
    do: expect(mock, :read_file, fn ^filename -> {filename, :after_read_file} end)

  defp expect_remove_program_changes(mock, filename, sequence),
    do:
      expect(mock, :remove_program_changes, fn {^filename, ^sequence} ->
        {filename, :after_remove_program_changes}
      end)

  defp expect_remove_unchanging_cc_val0(mock, filename, sequence),
    do:
      expect(mock, :remove_unchanging_cc_val0, fn {^filename, ^sequence} ->
        {filename, :after_remove_unchanging_cc_val0}
      end)

  defp expect_set_midi_channel(mock, filename, sequence, channel),
    do:
      expect(mock, :set_midi_channel, fn {^filename, ^sequence}, ^channel ->
        {filename, :after_set_midi_channel}
      end)

  defp expect_write_file(mock, filename, sequence, outfile),
    do:
      expect(mock, :write_file, fn {^filename, ^sequence}, ^outfile ->
        {filename, :after_write_file}
      end)
end
