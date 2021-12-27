defmodule MidiCleaner.RunnerTest do
  use ExUnit.Case
  doctest MidiCleaner.Runner

  alias MidiCleaner.{Config, Runner}

  describe "run(config)" do
    test "errors" do
      assert {:error, _} = Runner.run(config(file_list: []))
    end

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
end
