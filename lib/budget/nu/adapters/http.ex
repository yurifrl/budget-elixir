defmodule Budget.Nu.Adapters.Http do
  @discovery_endpoint "/api/discovery"
  @app_discovery_endpoint "/api/app/discovery"

  def discovery(opts) do
    [
      {Tesla.Middleware.BaseUrl, base_url(opts)}
      | get_middlewares()
    ]
    |> Tesla.client()
    |> Tesla.get!(@discovery_endpoint)
  end

  def discovery_app(opts) do
    [
      {Tesla.Middleware.BaseUrl, base_url(opts)}
      | get_middlewares()
    ]
    |> Tesla.client()
    |> Tesla.get!(@app_discovery_endpoint)
  end

  defp base_url(opts), do: Keyword.fetch!(opts, :base_url)

  defp get_middlewares do
    [
      Tesla.Middleware.FormUrlencoded,
      Tesla.Middleware.JSON,
      Tesla.Middleware.Query,
      {Tesla.Middleware.Cache, ttl: :timer.hours(10)}
      | default_middlewares()
    ]
  end

  defp default_middlewares do
    [
      {Tesla.Middleware.Timeout, timeout: :timer.minutes(1)},
      Tesla.Middleware.DecodeJson,
      Tesla.Middleware.Logger,
      Tesla.Middleware.PathParams
    ]
  end
end
