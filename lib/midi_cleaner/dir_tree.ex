defmodule MidiCleaner.DirTree do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def reset do
    GenServer.call(__MODULE__, :reset)
  end

  def mkdir_p(path) do
    GenServer.call(__MODULE__, {:mkdir_p, path})
  end

  @impl true
  def handle_call(:reset, _from, _state) do
    {:reply, :ok, %{}}
  end

  @impl true
  def handle_call({:mkdir_p, path}, _from, state) do
    components = Path.split(path)

    result =
      if get_in(state, components) do
        :exists
      else
        File.mkdir_p!(path)
        :created
      end

    {:reply, {:ok, result}, add(components, state)}
  end

  defp add(components, state) do
    put_in(state, Enum.map(components, &Access.key(&1, %{})), %{})
  end
end
