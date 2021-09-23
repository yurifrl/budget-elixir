defmodule Budget.Nu do
  alias Budget.Nu.Manager

  def discovery do
    Manager.discovery()
  end

  def token do
    Manager.token()
  end
end
