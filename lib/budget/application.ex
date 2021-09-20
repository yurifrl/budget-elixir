defmodule Budget.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    env = Application.fetch_env!(:budget, :env)

    children = [
      | children(env)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Budget.Supervisor]
    Supervisor.start_link(children, opts)
  end


  defp children(:test), do: []

  defp children(_env) do
    [{Budget.Nu.Manager, opts()}]
  end

  defp opts do
    Application.fetch_env!(:budget, Budget.Nu.Adapters.Http)
  end
end
