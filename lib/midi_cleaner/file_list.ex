defmodule MidiCleaner.FileList do
  defstruct files: [], dirs: []

  def new(paths \\ []) do
    {files, dirs} = Enum.split_with(paths, &(Path.extname(&1) == ".mid"))

    %__MODULE__{
      files: files,
      dirs: dirs
    }
  end

  def empty?(%{files: [], dirs: []}), do: true
  def empty?(%{files: _, dirs: _}), do: false

  def each_file(%{files: files, dirs: dirs}, func) do
    files_stream = Stream.map(files, &{&1, &1})
    dirs_stream = Stream.flat_map(dirs, &list_files/1)

    Stream.concat(files_stream, dirs_stream)
    |> Task.async_stream(func)
    |> Stream.run()
  end

  defp list_files(dir) do
    Path.wildcard("#{dir}/**/*.mid")
    |> Task.async_stream(&{&1, Path.relative_to(&1, dir)}, ordered: false)
    |> Stream.map(fn {:ok, file} -> file end)
  end
end
