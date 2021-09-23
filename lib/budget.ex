defmodule Budget do
  alias Budget.Nu.Manager

  def budget() do
    discovery = Manager.discovery()
    discovery |> IO.inspect(label: "====>>>> 5 discovery", pretty: true, limit: :infinity)

    token = Manager.token()
    token |> IO.inspect(label: "====>>>> 7 token", pretty: true, limit: :infinity)

    :ok
  end
end
