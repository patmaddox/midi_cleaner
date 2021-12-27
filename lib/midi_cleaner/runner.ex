defmodule MidiCleaner.Runner do
  @callback run(Map.t()) :: :ok

  alias MidiCleaner.Config

  def run(config) do
    with :ok <- Config.validate(config)
    do
      Enum.each(config.file_list, fn filename ->
        read_file(filename)
        |> maybe_remove_program_changes(config)
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

  defp maybe_remove_program_changes(sequence, _config), do: midi_cleaner().remove_program_changes(sequence)

  defp midi_cleaner do
    Application.get_env(:midi_cleaner, :midi_cleaner)
  end
end
