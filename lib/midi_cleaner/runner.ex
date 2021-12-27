defmodule MidiCleaner.Runner do
  @callback run(List.t()) :: :ok

  def run([]), do: []
  def run([command]), do: run_command(command)
  def run([command | rest]), do: run_command(command) |> run(rest)

  defp run(val, [command]), do: run_command(command, [val])
  defp run(val, [command | rest]), do: run_command(command, [val]) |> run(rest)

  defp run_command(command, args) when is_function(command), do: apply(command, args)
  defp run_command({command, args}, preargs), do: run_command(command, preargs ++ args)

  defp run_command(command) when is_function(command), do: run_command(command, [])
  defp run_command({command, args}), do: run_command(command, args)
end
