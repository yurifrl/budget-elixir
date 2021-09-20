defmodule Budget.Nu do
  def discovery, do: adapter().discovery(adapter_opts())

  defp opts, do: Application.get_env(:budget, __MODULE__, [])
  defp adapter, do: Keyword.fetch!(opts(), :adapter)
  defp adapter_opts, do: Application.get_env(:budget, adapter(), [])
end
