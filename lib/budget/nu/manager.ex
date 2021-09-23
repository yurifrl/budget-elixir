defmodule Budget.Nu.Manager do
  @moduledoc false

  use GenServer

  @ttl 1_000_000_000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def discovery do
    GenServer.call(__MODULE__, :discovery)
  end

  def token do
    GenServer.call(__MODULE__, :token)
  end

  @impl true
  def init(opts) do
    adapter = Keyword.fetch!(opts, :adapter)

    Process.send_after(self(), :discovery, @ttl)

    discovery = adapter.discovery(opts)
    token = adapter.token(discovery, opts)

    {:ok, %{discovery: discovery, adapter: adapter, token: token, opts: opts}}
  end

  @impl true
  def handle_call(:discovery, _from, %{discovery: discovery} = state) do
    {:reply, discovery, state}
  end

  @impl true
  def handle_call(:token, _from, %{token: token} = state) do
    {:reply, token, state}
  end

  @impl true
  def handle_info(:discovery, %{adapter: adapter} = state) do
    Process.send_after(self(), :discovery, @ttl)
    discovery = adapter.discovery()
    {:noreply, %{state | discovery: discovery}}
  end
end
