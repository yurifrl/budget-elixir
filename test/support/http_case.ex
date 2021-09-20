defmodule Budget.HttpCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using opts do
    port = Keyword.get(opts, :port)

    quote do
      import Budget.HttpCase

      setup context do
        bypass =
          case unquote(port) do
            nil -> Bypass.open()
            bypass_port -> Bypass.open(port: bypass_port)
          end

        base_url = "http://localhost:#{bypass.port}"

        %{bypass: bypass, base_url: base_url}
      end
    end
  end

  def setup_endpoint(bypass, opts) do
    ref = make_ref()
    parent_pid = self()

    status_code = Keyword.fetch!(opts, :status_code)
    response_body = Keyword.fetch!(opts, :response_body)

    Bypass.expect(bypass, fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)
      conn = Map.replace!(conn, :body_params, body)
      send(parent_pid, {:request, ref, conn})

      conn
      |> Plug.Conn.put_resp_header("content-type", "application/json")
      |> Plug.Conn.send_resp(status_code, Jason.encode!(response_body))
    end)

    ref
  end
end
