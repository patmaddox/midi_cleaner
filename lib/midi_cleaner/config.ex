defmodule MidiCleaner.Config do
  alias MidiCleaner.FileList

  defstruct file_list: [],
            output: nil,
            remove_program_changes: false,
            remove_unchanging_cc_val0: false,
            set_midi_channel: nil

  def new(overrides \\ %{}) do
    %__MODULE__{}
    |> Map.merge(overrides)
    |> Map.update(:file_list, FileList.new(), &FileList.new/1)
  end

  def validate(config) do
    []
    |> validate_commands(config)
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

  defp validate_commands(errors, %{
         remove_program_changes: pc,
         remove_unchanging_cc_val0: cc0,
         set_midi_channel: ch
       })
       when pc or cc0 or is_integer(ch),
       do: errors

  defp validate_commands(errors, _), do: [:no_commands | errors]
end
