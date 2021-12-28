defmodule MidiCleaner.Runner do
  @callback run(Map.t()) :: :ok

  alias MidiCleaner.{Config, FileList}

  def run(config) do
    with :ok <- Config.validate(config) do
      FileList.each_file(config.file_list, fn filename ->
        read_file(filename)
        |> maybe_remove_program_changes(config)
        |> maybe_remove_unchanging_cc_val0(config)
        |> maybe_set_midi_channel(config)
        |> write_file(filename, config)
      end)

      :ok
    else
      errors -> errors
    end
  end

  defp read_file(filename), do: midi_cleaner().read_file(filename)

  defp write_file(sequence, filename, config) do
    filename = Enum.join([config.output, filename], "/")
    midi_cleaner().write_file(sequence, filename)
  end

  defp maybe_remove_program_changes(sequence, %{remove_program_changes: true}),
    do: midi_cleaner().remove_program_changes(sequence)

  defp maybe_remove_program_changes(sequence, _config), do: sequence

  defp maybe_remove_unchanging_cc_val0(sequence, %{remove_unchanging_cc_val0: true}),
    do: midi_cleaner().remove_unchanging_cc_val0(sequence)

  defp maybe_remove_unchanging_cc_val0(sequence, _config), do: sequence

  defp maybe_set_midi_channel(sequence, %{set_midi_channel: ch}) when is_integer(ch),
    do: midi_cleaner().set_midi_channel(sequence, ch)

  defp maybe_set_midi_channel(sequence, _config), do: sequence

  defp midi_cleaner do
    Application.get_env(:midi_cleaner, :midi_cleaner)
  end
end
