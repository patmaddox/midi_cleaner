defmodule MidiCleaner.FileList do
  defstruct paths: []

  def new(paths \\ []) do
    %__MODULE__{
      paths: Enum.map(paths, &file_or_dir_tuple/1)
    }
  end

  def each_file(%{paths: paths}, func), do: Enum.each(paths, &process_path(&1, func))

  def each_parent_dir(%{paths: paths}, func), do: set_of_parent_dirs(paths) |> Enum.each(func)

  def empty?(%{paths: paths}), do: Enum.empty?(paths)

  defp file_or_dir_tuple(path) do
    if Path.extname(path) == ".mid" do
      {:file, path}
    else
      {:dir, path}
    end
  end

  defp process_path({:file, path}, func), do: func.(path)

  defp process_path({:dir, path}, func) do
    Path.wildcard("#{path}/**/*.mid")
    |> Enum.each(&process_path({:file, &1}, func))
  end

  defp set_of_parent_dirs(paths), do: set_of_parent_dirs(MapSet.new(), paths)

  defp set_of_parent_dirs(parent_dirs, []), do: parent_dirs

  defp set_of_parent_dirs(parent_dirs, [{:file, path} | rest]) do
    parent_dirs
    |> add_parent_dir(path)
    |> set_of_parent_dirs(rest)
  end

  defp set_of_parent_dirs(parent_dirs, [{:dir, path} | rest]) do
    Path.wildcard("#{path}/**/*.mid")
    |> Enum.reduce(parent_dirs, &add_parent_dir/2)
    |> set_of_parent_dirs(rest)
  end

  defp add_parent_dir(%MapSet{} = parent_dirs, path),
    do: MapSet.put(parent_dirs, Path.dirname(path))

  defp add_parent_dir(path, %MapSet{} = parent_dirs), do: add_parent_dir(parent_dirs, path)
end
