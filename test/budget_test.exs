defmodule BudgetTest do
  use ExUnit.Case, async: false

  alias Budget.Nu.Adapters.Http

  @moduletag :external

  setup do
    {:ok, %{opts: nu_opts() ++ nu_adapter_opts()}}
  end

  test "integration test", context do
    %{opts: opts} = context
    discovery = Http.discovery(opts)
    discovery |> IO.inspect(label: "====>>>> discovery ", pretty: true, limit: :infinity)

    token = Http.token(discovery, opts)
    token |> IO.inspect(label: "====>>>> token ", pretty: true, limit: :infinity)

    events = Http.events(token, opts)
    events |> IO.inspect(label: "====>>>> events ", pretty: true, limit: :infinity)

    feed = Http.feed(token, opts)
    feed |> IO.inspect(label: "====>>>> feed ", pretty: true, limit: :infinity)
  end

  defp nu_adapter_opts, do: Application.get_env(:budget, nu_adapter(), [])
  defp nu_adapter, do: Keyword.fetch!(nu_opts(), :adapter)
  defp nu_opts, do: Application.get_env(:budget, Budget.Nu, [])
end
