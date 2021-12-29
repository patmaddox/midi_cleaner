defmodule MidiCleaner.DirTreeTest do
  use ExUnit.Case
  doctest MidiCleaner.DirTree

  alias MidiCleaner.DirTree

  @test_dir "/tmp/dir_tree"

  setup [:remove_test_dir, :reset_dir_tree]

  describe "mkdir_p" do
    test "make a dir" do
      dir = dir("foo/bar/baz")

      refute File.dir?(dir)
      assert {:ok, :created} == DirTree.mkdir_p(dir)
      assert File.dir?(dir)
    end

    test "don't make a dir if it parent already exists" do
      dir = dir("foo/bar")

      refute File.dir?(dir)
      assert {:ok, :created} == DirTree.mkdir_p(Path.join(dir, "baz"))
      assert File.dir?(dir)
      assert {:ok, :exists} == DirTree.mkdir_p(dir)
      assert File.dir?(dir)
    end

    test "make a dir if it goes deeper" do
      dir = dir("foo/bar")

      assert {:ok, :created} == DirTree.mkdir_p(dir)
      assert {:ok, :created} == DirTree.mkdir_p(Path.join(dir, "baz"))
      assert File.dir?(dir)
    end
  end

  defp remove_test_dir(_context) do
    File.rm_rf!(@test_dir)
    :ok
  end

  defp reset_dir_tree(_context) do
    :ok = DirTree.reset()
  end

  defp dir(path), do: Path.join(@test_dir, path)
end
