defmodule MidiCleaner.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias MidiCleaner.{DirTree, StatsServer}

  @impl true
  def start(_type, _args) do
    children = [
      {StatsServer, []},
      {DirTree, []}
    ]

    # span events also do :start and :exception but I don't care about those right now
    :telemetry.attach_many(
      "midi-cleaner.stats",
      [
        [:midi_cleaner, :file_processor, :read_file, :stop],
        [:midi_cleaner, :file_processor, :process, :stop],
        [:midi_cleaner, :file_processor, :write_file, :stop],
        [:midi_cleaner, :runner, :run, :stop],
        [:midi_cleaner, :runner, :make_output_dir, :stop],
        [:midi_cleaner, :runner, :process_file, :stop]
      ],
      &StatsServer.handle_event/4,
      nil
    )

    opts = [strategy: :one_for_one, name: MidiCleaner.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
