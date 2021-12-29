defmodule MidiCleaner.Commands.RemoveUnchangingCcVal0 do
  alias Midifile.Event

  def preview_events(events), do: [controls_to_keep(events)]

  def process_event(event, controls_to_keep) do
    if keep_event?(event, controls_to_keep) do
      event
    else
      :drop
    end
  end

  defp controls_to_keep(events) do
    events
    |> Stream.filter(&keep_control?/1)
    |> Stream.map(&cc/1)
    |> MapSet.new()
  end

  defp keep_control?(%Event{symbol: :controller, bytes: [_, _, val]}) when val > 0, do: true
  defp keep_control?(_), do: false

  defp keep_event?(%Event{symbol: :controller} = event, controls_to_keep),
    do: MapSet.member?(controls_to_keep, cc(event))

  defp keep_event?(_, _), do: true

  defp cc(%Event{bytes: [_, cc, _]}), do: cc
end
