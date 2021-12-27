defmodule MidiCleaner.Runner do
  @callback run(Map.t()) :: :ok

  def run(config) do
    with [] <- validate(config) do
      :ok
    else
      errors -> {:error, errors}
    end
  end

  defp validate(config) do
    []
    |> validate_file_list(config)
    |> validate_output(config)
    |> validate_commands(config)
  end

  defp validate_file_list(errors, %{file_list: file_list}) when length(file_list) == 0,
    do: [:no_file_list | errors]

  defp validate_file_list(errors, _), do: errors

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
