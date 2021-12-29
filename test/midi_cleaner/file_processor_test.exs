defmodule MidiCleaner.FileProcessorTest do
  use ExUnit.Case
  doctest MidiCleaner.Runner

  import Mox

  alias MidiCleaner.{Config, FileProcessor, MockMidiCleaner}

  setup :verify_on_exit!

  # The function calls are inline here because we need access to the pid
  # to allow Mox.
  test "process_file(config, infile, outfile)" do
    {:ok, pid} = FileProcessor.start_link([])

    config =
      %{
        file_list: ["example.mid", "files/example.mid", "example/midi"],
        output: "export/clean",
        processors: [Foo, Bar, Baz]
      }
      |> Config.new()

    :ok =
      FileProcessor.configure(
        pid,
        config,
        "in.mid",
        "out.mid"
      )

    MockMidiCleaner
    |> expect_read_file("in.mid")
    |> expect_process("in.mid", :after_read_file, [Foo, Bar, Baz])
    |> expect_write_file(
      "in.mid",
      :after_process,
      "export/clean/out.mid"
    )
    |> allow(self(), pid)

    :ok = FileProcessor.process(pid)
  end

  defp expect_read_file(mock, filename) do
    expect(mock, :read_file, fn ^filename -> {filename, :after_read_file} end)
  end

  defp expect_process(mock, filename, sequence, processors) do
    expect(mock, :process, fn {^filename, ^sequence}, ^processors ->
      {filename, :after_process}
    end)
  end

  defp expect_write_file(mock, filename, sequence, outfile) do
    expect(mock, :write_file, fn {^filename, ^sequence}, ^outfile ->
      {filename, :after_write_file}
    end)
  end
end
