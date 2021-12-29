defmodule MidiCleaner.Commands.RemoveProgramChanges do
  alias Midifile.Event

  def preview_events(_), do: []

  def process_event(event) do
    if event_is_program_change?(event) do
      :drop
    else
      event
    end
  end

  defp event_is_program_change?(%Event{symbol: :program}), do: true
  defp event_is_program_change?(%Event{}), do: false
end
