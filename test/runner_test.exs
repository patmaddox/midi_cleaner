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
      |> expect(:read_file, fn filename ->
        assert filename == "example.mid"
        :sequence_after_read_file
      end)
      |> expect(:remove_unchanging_cc_val0, fn sequence ->
        assert sequence == :sequence_after_read_file
        :sequence_after_remove_unchanging_cc_val0
      end)
      |> expect(:write_file, fn sequence, outfile ->
        assert sequence == :sequence_after_remove_unchanging_cc_val0
        assert outfile == "export/clean/example.mid"
        :after_write_file
      end)

      config =
        no_commands(
          file_list: ["example.mid"],
          remove_unchanging_cc_val0: true
        )

      assert :ok == Runner.run(config)
    end

    test "one file, different command" do
      MockMidiCleaner
      |> expect(:read_file, fn filename ->
        assert filename == "example.mid"
        :sequence_after_read_file
      end)
      |> expect(:remove_program_changes, fn sequence ->
        assert sequence == :sequence_after_read_file
        :sequence_after_remove_program_changes
      end)
      |> expect(:write_file, fn sequence, outfile ->
        assert sequence == :sequence_after_remove_program_changes
        assert outfile == "export/clean/example.mid"
        :after_write_file
      end)

      config =
        no_commands(
          file_list: ["example.mid"],
          remove_program_changes: true
        )

      assert :ok == Runner.run(config)
    end

    test "one file, all commands" do
      MockMidiCleaner
      |> expect(:read_file, fn filename ->
        assert filename == "example.mid"
        :sequence_after_read_file
      end)
      |> expect(:remove_program_changes, fn sequence ->
        assert sequence == :sequence_after_read_file
        :sequence_after_remove_program_changes
      end)
      |> expect(:remove_unchanging_cc_val0, fn sequence ->
        assert sequence == :sequence_after_remove_program_changes
        :sequence_after_remove_unchanging_cc_val0
      end)
      |> expect(:set_midi_channel, fn sequence, channel ->
        assert sequence == :sequence_after_remove_unchanging_cc_val0
        assert channel == 0
        :sequence_after_set_midi_channel
      end)
      |> expect(:write_file, fn sequence, outfile ->
        assert sequence == :sequence_after_set_midi_channel
        assert outfile == "export/clean/example.mid"
        :after_write_file
      end)

      config = config(file_list: ["example.mid"])
      assert :ok == Runner.run(config)
    end

    @tag :skip
    test "full config" do
      assert :ok == Runner.run(config())
    end
  end

  def config(overrides \\ []) do
    %Config{
      file_list: ["example.mid", "files/example.mid", "example/midi"],
      output: "export/clean",
      remove_program_changes: true,
      remove_unchanging_cc_val0: true,
      set_midi_channel: 0
    }
    |> Map.merge(Map.new(overrides))
  end

  def no_commands(overrides \\ []) do
    [
      remove_program_changes: false,
      remove_unchanging_cc_val0: false,
      set_midi_channel: nil
    ]
    |> Keyword.merge(overrides)
    |> config()
  end
end
