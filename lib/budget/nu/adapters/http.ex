defmodule Budget.Nu.Adapters.Http do
  @behaviour Budget.Nu.Adapter

  @discovery_endpoint "/api/app/discovery"
  @feed_query "{
    viewer {
      savingsAccount {
        id
        feed {
          id
          __typename
          title
          detail
          postDate
          ... on TransferInEvent {
            amount
            originAccount {
              name
            }
          }
          ... on TransferOutEvent {
            amount
            destinationAccount {
              name
            }
          }
          ... on TransferOutReversalEvent {
            amount
          }
          ... on BillPaymentEvent {
            amount
          }
          ... on DebitPurchaseEvent {
            amount
          }
          ... on BarcodePaymentEvent {
            amount
          }
          ... on DebitWithdrawalFeeEvent {
            amount
          }
          ... on DebitWithdrawalEvent {
            amount
          }
        }
      }
    }
  }"
  def discovery(opts) do
    [
      {Tesla.Middleware.BaseUrl, base_url(opts)}
      | get_middlewares()
    ]
    |> Tesla.client()
    |> Tesla.get!(@discovery_endpoint)
    |> ensure_successful_response!()
  end

  def token(urls, opts) do
    [
      {Tesla.Middleware.BaseUrl, token_url(urls)}
      | default_middlewares()
    ]
    |> Tesla.client()
    |> Tesla.post!("", token_body(opts), adapter_opts(opts))
    |> ensure_successful_response!()
  end

  def events(urls, opts) do
    [
      {Tesla.Middleware.BaseUrl, events_url(urls)},
      {Tesla.Middleware.BearerAuth, token: get_token(urls)}
      | get_middlewares()
    ]
    |> Tesla.client()
    |> Tesla.get!("", adapter_opts(opts))
    |> ensure_successful_response!()
  end

  def feed(urls, opts) do
    [
      {Tesla.Middleware.BaseUrl, feed_url(urls)},
      {Tesla.Middleware.BearerAuth, token: get_token(urls)}
      | default_middlewares()
    ]
    |> Tesla.client()
    |> Tesla.post!("", feed_body(), adapter_opts(opts))
    |> ensure_successful_response!()
  end

  defp adapter_opts(opts) do
    [
      opts: [
        adapter: [
          ssl: [
            certfile: cert_path(opts),
            keyfile: key_path(opts)
          ]
        ]
      ]
    ]
  end

  defp default_middlewares do
    [
      {Tesla.Middleware.Headers,
       [
         {"X-Correlation-Id", "WEB-APP.pewW9"},
         {"User-Agent",
          "yurifrl/budget-elixir Client - https://github.com/yurifrl/budget-elixir"},
         {"Content-Type", "application/json"}
       ]},
      {Tesla.Middleware.Timeout, timeout: :timer.minutes(1)},
      Tesla.Middleware.DecodeJson,
      Tesla.Middleware.Logger,
      Tesla.Middleware.PathParams,
      Tesla.Middleware.JSON,
      Tesla.Middleware.Query
    ]
  end

  defp get_middlewares do
    [
      Tesla.Middleware.FormUrlencoded,
      {Tesla.Middleware.Cache, ttl: :timer.hours(10)}
      | default_middlewares()
    ]
  end

  defp ensure_successful_response!(%{status: status, body: body}) when status in 200..299 do
    body
  end

  defp ensure_successful_response!(tesla) do
    raise """
    Unexpected response:
    Url: #{tesla.url}
    Status code: #{tesla.status}
    Method: #{tesla.method}
    Response body:
    #{inspect(tesla.body)}
    ---
    Tesla Env:
    #{inspect(tesla)}
    """
  end

  defp base_url(opts), do: Keyword.fetch!(opts, :base_url)
  defp cert_path(opts), do: Keyword.fetch!(opts, :cert_path)
  defp key_path(opts), do: Keyword.fetch!(opts, :key_path)
  defp username(opts), do: Keyword.fetch!(opts, :username)
  defp password(opts), do: Keyword.fetch!(opts, :password)

  defp token_body(opts),
    do: %{
      grant_type: "password",
      client_id: "legacy_client_id",
      client_secret: "legacy_client_secret",
      login: username(opts),
      password: password(opts)
    }

  defp token_url(params), do: Map.fetch!(params, "token")

  defp events_url(params),
    do: Map.fetch!(params, "_links") |> Map.fetch!("events") |> Map.fetch!("href")

  defp feed_url(params),
    do: Map.fetch!(params, "_links") |> Map.fetch!("ghostflame") |> Map.fetch!("href")

  defp get_token(params), do: Map.fetch!(params, "access_token")

  defp feed_body(), do: %{variables: %{}, query: @feed_query}
end
