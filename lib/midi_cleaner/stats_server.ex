defmodule MidiCleaner.StatsServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state), do: {:ok, state}

  def handle_event(
        [:midi_cleaner, module, function, :stop],
        %{duration: duration},
        _metadata,
        _config
      ) do
    milliseconds = System.convert_time_unit(duration, :native, :millisecond)
    record({module, function}, milliseconds)
  end

  def reset, do: GenServer.cast(__MODULE__, :reset)

  def record(id, value) do
    GenServer.cast(__MODULE__, {:record, id, value})
  end

  def report do
    GenServer.call(__MODULE__, :report)
  end

  def inspect do
    report() |> IO.inspect(label: __MODULE__)
  end

  @impl true
  def handle_cast(:reset, _stats), do: {:noreply, %{}}

  @impl true
  def handle_cast({:record, id, value}, all_stats) do
    stats =
      stats_for(all_stats, id)
      |> update_stats(value)

    {:noreply, Map.put(all_stats, id, stats)}
  end

  @impl true
  def handle_call(:report, _from, stats) do
    {:reply, stats, stats}
  end

  defp stats_for(stats, id) when is_map_key(stats, id), do: Map.get(stats, id)
  defp stats_for(_stats, _id), do: new_stats()

  defp new_stats do
    %{
      count: 0,
      average: 0
    }
  end

  defp update_stats(stats, value) do
    stats
    |> update_count(value)
    |> update_average(value)
    |> update_min(value)
    |> update_max(value)
  end

  defp update_count(%{count: count} = stats, _value) do
    Map.put(stats, :count, count + 1)
  end

  defp update_average(%{count: count, average: average} = stats, value) do
    Map.put(stats, :average, (average * (count - 1) + value) / count)
  end

  defp update_min(stats, value) when not is_map_key(stats, :min) do
    Map.put(stats, :min, value)
  end

  defp update_min(%{min: min} = stats, value) when value < min do
    Map.put(stats, :min, value)
  end

  defp update_min(stats, _value), do: stats

  defp update_max(stats, value) when not is_map_key(stats, :max) do
    Map.put(stats, :max, value)
  end

  defp update_max(%{max: max} = stats, value) when value > max do
    Map.put(stats, :max, value)
  end

  defp update_max(stats, _value), do: stats
end
