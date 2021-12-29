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

    test "no processors" do
      assert Config.validate(config(processors: [])) == {:error, [:no_processors]}
    end

    test "empty config" do
      config = config(file_list: [], output: nil, processors: [])
      assert Config.validate(config) == {:error, [:no_file_list, :no_output, :no_processors]}
    end

    test "full config" do
      assert Config.validate(config()) == :ok
    end
  end

  def config(overrides \\ []) do
    %{
      file_list: ["example.mid", "files/example.mid", "example/midi"],
      output: "export/clean",
      processors: [Foo, Bar, Baz]
    }
    |> Map.merge(Map.new(overrides))
    |> Config.new()
  end
end
