defmodule MidiCleaner.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias MidiCleaner.DirTree

  @impl true
  def start(_type, _args) do
    children = [
      {DirTree, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MidiCleaner.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
