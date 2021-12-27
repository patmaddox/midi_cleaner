defmodule MidiCleaner.RunnerTest do
  use ExUnit.Case
  doctest MidiCleaner.Runner

  alias MidiCleaner.{Config, Runner}

  describe "run()" do
    test "no file list" do
      config = config(file_list: [])
      assert Runner.run(config) == {:error, [:no_file_list]}
    end

    test "no output" do
      config = config(output: nil)
      assert Runner.run(config) == {:error, [:no_output]}
    end

    test "no commands" do
      config =
        config(
          remove_program_changes: false,
          remove_unchanging_cc_val0: false,
          set_midi_channel: nil
        )

      assert Runner.run(config) == {:error, [:no_commands]}
    end

    test "full config" do
      assert Runner.run(config()) == :ok
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
end
