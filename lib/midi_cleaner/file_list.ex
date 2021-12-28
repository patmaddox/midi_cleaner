defmodule MidiCleaner.FileList do
  defstruct paths: []

  def new(paths \\ []) do
    %__MODULE__{
      paths: Enum.map(paths, &file_or_dir_tuple/1)
    }
  end

  def empty?(%{paths: paths}), do: Enum.empty?(paths)

  def files(%{paths: paths}), do: list_files(paths)

  def dirs(%{paths: paths}), do: list_dirs(MapSet.new(), paths)

  defp file_or_dir_tuple(path) do
    if Path.extname(path) == ".mid" do
      {:file, path}
    else
      {:dir, path}
    end
  end

  defp list_files([]), do: []

  defp list_files([{:file, path} | rest]) do
    [{path, path} | list_files(rest)]
  end

  defp list_files([{:dir, path} | rest]) do
    Path.wildcard("#{path}/**/*.mid")
    |> Enum.map(&{&1, Path.relative_to(&1, path)})
    |> list_files(rest)
  end

  defp list_files([{_, _} = first | rest], full_list) do
    [first | list_files(rest, full_list)]
  end

  defp list_files([], []), do: []

  defp list_dirs(dirs, []), do: dirs

  defp list_dirs(dirs, [{:file, path} | rest]) do
    dirs
    |> MapSet.put(Path.dirname(path))
    |> list_dirs(rest)
  end

  defp list_dirs(dirs, [{:dir, path} | rest]) do
    Path.wildcard("#{path}/**/*.mid")
    |> Stream.map(&Path.dirname/1)
    |> Stream.map(&Path.relative_to(&1, path))
    |> MapSet.new()
    |> MapSet.union(dirs)
    |> list_dirs(rest)
  end

  defp list_dirs(dirs, [first | rest]) do
    dirs
    |> MapSet.put(first)
    |> list_dirs(rest)
  end
end
