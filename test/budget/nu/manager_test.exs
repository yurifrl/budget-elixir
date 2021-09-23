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

      NuMock
      |> stub(:discovery, fn _ ->
        %{foo: "bar"}
      end)
      |> stub(:token, fn _, _ ->
        %{token: "foo"}
      end)

      start_supervised!({Manager, options})

      assert %{foo: "bar"} = Manager.discovery()
      assert %{foo: "bar"} = Manager.discovery()
    end
  end
end
