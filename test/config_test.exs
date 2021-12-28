defmodule MidiCleaner.ConfigTest do
  use ExUnit.Case
  doctest MidiCleaner.Config

  alias MidiCleaner.Config

  describe "validate()" do
    test "no file list" do
      config = config(file_list: [])
      assert Config.validate(config) == {:error, [:no_file_list]}
    end

    test "no output" do
      config = config(output: nil)
      assert Config.validate(config) == {:error, [:no_output]}
    end

    test "no commands" do
      assert Config.validate(no_commands()) == {:error, [:no_commands]}
    end

    test "empty config" do
      config = no_commands(file_list: [], output: nil)
      assert Config.validate(config) == {:error, [:no_file_list, :no_output, :no_commands]}
    end

    test "full config" do
      assert Config.validate(config()) == :ok
    end

    test "any command" do
      assert Config.validate(no_commands(remove_program_changes: true)) == :ok
      assert Config.validate(no_commands(remove_unchanging_cc_val0: true)) == :ok
      assert Config.validate(no_commands(set_midi_channel: 0)) == :ok
    end
  end

  def config(overrides \\ []) do
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
