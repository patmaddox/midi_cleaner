defmodule MidiCleaner.Commands.SetMidiChannel do
  alias MidiCleaner.Error

  def make_processor(new_channel) when new_channel >= 0 and new_channel <= 15 do
    channel_module = String.to_atom("Elixir.MidiCleaner.Commands.SetMidiChannel#{new_channel}")

    unless :code.module_status(channel_module) == :loaded do
      defmodule channel_module do
        alias Midifile.Event
        @new_channel new_channel

        def process_event(event) do
          if Event.channel?(event) do
            [first | rest] = event.bytes
            orig_channel = Event.channel(event)
            first = first - orig_channel + @new_channel
            struct(event, bytes: [first | rest])
          else
            event
          end
        end
      end
    end

    channel_module
  end

  def make_processor(channel) do
    raise Error, "Bad MIDI channel: #{channel}"
  end
end
