defmodule MidiCleaner.FileList do
  defstruct paths: []

  def new(paths) do
    %__MODULE__{
      paths: Enum.map(paths, &file_or_dir_tuple/1)
    }
  end

  def each_file(%{paths: paths}, func), do: Enum.each(paths, &process_path(&1, func))

  defp file_or_dir_tuple(path) do
    if Path.extname(path) == ".mid" do
      {:file, path}
    else
      {:dir, path}
    end
  end

  def process_path({:file, path}, func), do: func.(path)

  def process_path({:dir, path}, func) do
    Path.wildcard("#{path}/**/*.mid")
    |> Enum.each(&process_path({:file, &1}, func))
  end
end
