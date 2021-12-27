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
      |> expect_read_file("example.mid", :sequence_after_read_file)
      |> expect_remove_unchanging_cc_val0(
        :sequence_after_read_file,
        :sequence_after_remove_unchanging_cc_val0
      )
      |> expect_write_file(
        :sequence_after_remove_unchanging_cc_val0,
        "export/clean/example.mid",
        :after_write_file
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
      |> expect_read_file("example.mid", :sequence_after_read_file)
      |> expect_remove_program_changes(
        :sequence_after_read_file,
        :sequence_after_remove_program_changes
      )
      |> expect_write_file(
        :sequence_after_remove_program_changes,
        "export/clean/example.mid",
        :after_write_file
      )

      config =
        no_commands(
          file_list: ["example.mid"],
          remove_program_changes: true
        )

      assert :ok == Runner.run(config)
    end

    test "one file, all commands" do
      MockMidiCleaner
      |> expect_read_file("example.mid", :sequence_after_read_file)
      |> expect_remove_program_changes(
        :sequence_after_read_file,
        :sequence_after_remove_program_changes
      )
      |> expect_remove_unchanging_cc_val0(
        :sequence_after_remove_program_changes,
        :sequence_after_remove_unchanging_cc_val0
      )
      |> expect_set_midi_channel(
        :sequence_after_remove_unchanging_cc_val0,
        0,
        :sequence_after_set_midi_channel
      )
      |> expect_write_file(
        :sequence_after_set_midi_channel,
        "export/clean/example.mid",
        :after_write_file
      )

      config = config(file_list: ["example.mid"])
      assert :ok == Runner.run(config)
    end

    @tag :skip
    test "full config" do
      assert :ok == Runner.run(config())
    end
  end

  defp config(overrides \\ []) do
    %Config{
      file_list: ["example.mid", "files/example.mid", "example/midi"],
      output: "export/clean",
      remove_program_changes: true,
      remove_unchanging_cc_val0: true,
      set_midi_channel: 0
    }
    |> Map.merge(Map.new(overrides))
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

  defp expect_read_file(mock, filename, result),
    do: expect(mock, :read_file, fn ^filename -> result end)

  defp expect_remove_program_changes(mock, sequence, result),
    do: expect(mock, :remove_program_changes, fn ^sequence -> result end)

  defp expect_remove_unchanging_cc_val0(mock, sequence, result),
    do: expect(mock, :remove_unchanging_cc_val0, fn ^sequence -> result end)

  defp expect_set_midi_channel(mock, sequence, channel, result),
    do: expect(mock, :set_midi_channel, fn ^sequence, ^channel -> result end)

  defp expect_write_file(mock, sequence, filename, result),
    do: expect(mock, :write_file, fn ^sequence, ^filename -> result end)
end
