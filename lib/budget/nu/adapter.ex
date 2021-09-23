defmodule Budget.Nu.Adapter do
  @moduledoc false

  @callback discovery(keyword()) :: any()
  @callback token(map(), keyword()) :: any()
end
