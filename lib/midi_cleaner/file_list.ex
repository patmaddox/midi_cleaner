defmodule MidiCleaner.FileList do
  defstruct paths: []

  def new(paths \\ []) do
    %__MODULE__{
      paths: Enum.map(paths, &file_or_dir_tuple/1)
    }
  end

  def each_file(%{paths: paths}, func), do: Enum.each(paths, &process_path(&1, func))

  def each_dir(%{paths: paths}, func), do: set_of_dirs(paths) |> Enum.each(func)

  def empty?(%{paths: paths}), do: Enum.empty?(paths)

  defp file_or_dir_tuple(path) do
    if Path.extname(path) == ".mid" do
      {:file, path}
    else
      {:dir, path}
    end
  end

  defp process_path({:file, path}, func), do: func.({path, path})

  defp process_path({:dir, path}, func) do
    Path.wildcard("#{path}/**/*.mid")
    |> Enum.each(&func.({&1, Path.relative_to(&1, path)}))
  end

  defp set_of_dirs(paths), do: set_of_dirs(MapSet.new(), paths)

  defp set_of_dirs(dirs, []), do: dirs

  defp set_of_dirs(dirs, [{:file, path} | rest]) do
    dirs
    |> add_dir(path)
    |> set_of_dirs(rest)
  end

  defp set_of_dirs(dirs, [{:dir, path} | rest]) do
    Path.wildcard("#{path}/**/*.mid")
    |> Stream.map(&Path.relative_to(&1, path))
    |> Enum.reduce(dirs, &add_dir/2)
    |> set_of_dirs(rest)
  end

  defp add_dir(%MapSet{} = dirs, path), do: MapSet.put(dirs, Path.dirname(path))

  defp add_dir(path, %MapSet{} = dirs), do: add_dir(dirs, path)
end
