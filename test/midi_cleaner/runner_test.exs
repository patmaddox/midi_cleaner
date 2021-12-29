defmodule MidiCleaner.RunnerTest do
  use ExUnit.Case
  doctest MidiCleaner.Runner

  import Mox

  alias MidiCleaner.{Config, Runner, MockMidiCleaner, MockFileProcessor}

  setup :verify_on_exit!

  describe "run(config)" do
    test "errors" do
      pid =
        config(file_list: [])
        |> new_runner()

      assert {:error, _} = Runner.run(pid)
    end

    test "success" do
      config = config(file_list: ["drums/example.mid"])
      pid = new_runner(config)

      expect_make_dir("export/clean/drums")
      expect_process_file(config, "drums/example.mid", "drums/example.mid")

      assert :ok == Runner.run(pid)
    end
  end

  defp new_runner(config) do
    {:ok, pid} = Runner.new(config)

    allow(MockMidiCleaner, self(), pid)
    allow(MockFileProcessor, self(), pid)

    pid
  end

  defp config(overrides) do
    %{
      file_list: ["example.mid", "files/example.mid", "example/midi"],
      output: "export/clean",
      processors: [Foo, Bar, Baz]
    }
    |> Map.merge(Map.new(overrides))
    |> Config.new()
  end

  defp expect_make_dir(dir),
    do: expect(MockMidiCleaner, :make_dir, fn ^dir -> {dir, :after_make_dir} end)

  defp expect_process_file(config, infile, outfile) do
    expect(MockFileProcessor, :process_file, fn ^config, ^infile, ^outfile ->
      :ok
    end)
  end
end
