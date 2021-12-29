defmodule MidiCleaner.Config do
  alias MidiCleaner.FileList

  defstruct file_list: [],
            output: nil,
            processors: []

  def new(overrides \\ %{}) do
    %__MODULE__{}
    |> Map.merge(overrides)
    |> Map.update(:file_list, FileList.new(), &FileList.new/1)
  end

  def validate(config) do
    []
    |> validate_processors(config)
    |> validate_output(config)
    |> validate_file_list(config)
    |> case do
      [] -> :ok
      errors -> {:error, errors}
    end
  end

  defp validate_file_list(errors, %{file_list: file_list}) do
    if FileList.empty?(file_list) do
      [:no_file_list | errors]
    else
      errors
    end
  end

  defp validate_output(errors, %{output: output}) when is_nil(output), do: [:no_output | errors]
  defp validate_output(errors, _), do: errors

  defp validate_processors(errors, %{processors: processors}) when length(processors) > 0,
    do: errors

  defp validate_processors(errors, _), do: [:no_processors | errors]
end
