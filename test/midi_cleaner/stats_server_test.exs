defmodule MidiCleaner.StatsServerTest do
  use ExUnit.Case
  doctest MidiCleaner.StatsServer

  alias MidiCleaner.StatsServer

  setup :reset_stats_server

  test "record and report for one item" do
    :ok = StatsServer.record({:foo, :bar}, 2)
    :ok = StatsServer.record({:foo, :bar}, 1)
    :ok = StatsServer.record({:foo, :bar}, 3)

    :ok = StatsServer.record({:FOO, :BAR}, 20)
    :ok = StatsServer.record({:FOO, :BAR}, 10)
    :ok = StatsServer.record({:FOO, :BAR}, 30)

    assert StatsServer.report() == %{
             {:foo, :bar} => %{
               count: 3,
               average: 2,
               min: 1,
               max: 3
             },
             {:FOO, :BAR} => %{
               count: 3,
               average: 20,
               min: 10,
               max: 30
             }
           }
  end

  def reset_stats_server(_config) do
    :ok = StatsServer.reset()
  end
end
