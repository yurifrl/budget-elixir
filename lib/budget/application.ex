defmodule Budget.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    env = Application.fetch_env!(:budget, :env)

    children = [] ++ children(env)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Budget.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp children(:test), do: []

  defp children(_env) do
    [{Budget.Nu.Manager, nu_manager_opts()}]
  end

  defp nu_adapter_opts, do: Application.get_env(:budget, nu_adapter(), [])
  defp nu_adapter, do: Keyword.fetch!(nu_opts(), :adapter)
  defp nu_manager_opts, do: nu_opts() ++ nu_adapter_opts()
  defp nu_opts, do: Application.get_env(:budget, Budget.Nu, [])
end
