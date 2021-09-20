defmodule Budget.Nu.ManagerTest do
  use ExUnit.Case, async: false

  import Mox

  alias Budget.Nu.Adapters.Test, as: NuMock
  alias Budget.Nu.Manager

  setup :set_mox_global
  setup :verify_on_exit!

  setup do
    options = [
      adapter: NuMock
    ]

    %{options: options}
  end

  describe "Manager" do
    test "sucess", context do
      %{options: options} = context

      test_pid = self()

      NuMock
      |> stub(:discovery, fn ->
        send(test_pid, :discovery)

        %{}
      end)

      start_supervised!({Manager, options})

      assert_received :discovery
    end
  end
end
