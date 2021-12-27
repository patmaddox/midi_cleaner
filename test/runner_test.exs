defmodule MidiCleaner.RunnerTest do
  use ExUnit.Case
  doctest MidiCleaner.Runner

  alias MidiCleaner.Runner

  describe "run()" do
    test "no args" do
      assert Runner.run([]) == []
    end

    test "one command" do
      commands = [&__MODULE__.foo/0]
      assert Runner.run(commands) == "foo"
    end

    test "two commands" do
      commands = [
        &__MODULE__.foo/0,
        &String.upcase/1
      ]

      assert Runner.run(commands) == "FOO"
    end

    test "three commands" do
      commands = [
        &__MODULE__.foo/0,
        &String.upcase/1,
        &String.reverse/1
      ]

      assert Runner.run(commands) == "OOF"
    end

    test "one command with arg" do
      commands = [{&String.upcase/1, ["foo"]}]
      assert Runner.run(commands) == "FOO"
    end

    test "two commands with args" do
      commands = [
        {&String.upcase/1, ["foo"]},
        {&String.replace/3, ["OO", "BAR"]}
      ]

      assert Runner.run(commands) == "FBAR"
    end

    test "three commands with args" do
      commands = [
        {&String.upcase/1, ["foo"]},
        {&String.replace/3, ["OO", "BAR"]},
        {&String.slice/2, [0..1]}
      ]

      assert Runner.run(commands) == "FB"
    end

    test "batch commands" do
      commands = [
        [&__MODULE__.foo/0],
        [
          {&String.upcase/1, ["foo"]},
          {&String.replace/3, ["OO", "BAR"]},
          {&String.slice/2, [0..1]}
        ]
      ]

      assert Runner.run(commands) == ["foo", "FB"]
    end
  end

  def foo, do: "foo"
end
