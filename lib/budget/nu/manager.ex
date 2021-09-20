defmodule Budget.Nu.Manager do
  @moduledoc false

  use GenServer

  @ttl 10000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_token do
    GenServer.call(__MODULE__, :get_token)
  end

  @impl true
  def init(opts) do
    adapter = Keyword.fetch!(opts, :adapter)

    case adapter.discovery() do
      response ->
        # Process.send_after(self(), :discovery, @ttl)

        {:ok, %{discovery: response, adapter: adapter, opts: opts}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_call(:get_discovery, _from, %{discovery: discovery} = state) do
    {:reply, discovery, state}
  end

  @impl true
  def handle_info(:discovery, %{adapter: adapter} = state) do
    response = adapter.discovery()

    # Process.send_after(self(), :discovery, @ttl)

    {:noreply, %{state | discovery: response}}
  end
end
