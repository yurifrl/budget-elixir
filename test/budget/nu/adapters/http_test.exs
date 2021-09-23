defmodule Budget.Nu.Adapters.HttpTest do
  use Budget.HttpCase, async: true

  alias Budget.Nu.Adapters.Http

  @customer_id "3bcceb1c-1c0e-11ec-9621-0242ac130002"
  @account_id "408edeb2-1c0e-11ec-9621-0242ac130002"
  @access_token "access_token"

  @account_feed_query "{
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

  describe "discovery/1" do
    test "successful response", context do
      %{bypass: bypass, base_url: base_url} = context

      setup_ref =
        setup_endpoint(
          bypass,
          status_code: 200,
          response_body: build_discovery_app_response(base_url)
        )

      assert %{"token" => _} = Http.discovery(base_url: base_url)

      assert_received {:request, ^setup_ref, conn}

      assert %Plug.Conn{
               method: "GET",
               request_path: "/api/app/discovery",
               req_headers: req_headers
             } = conn

      assert {"content-type", "application/json"} in req_headers
    end
  end

  describe "token/2" do
    test "successful response", context do
      %{bypass: bypass, base_url: base_url} = context

      setup_ref =
        setup_endpoint(
          bypass,
          status_code: 200,
          response_body: build_token_response(base_url)
        )

      assert %{
               "_links" => _,
               "access_token" => _,
               "refresh_before" => _,
               "refresh_token" => _,
               "token_type" => "bearer"
             } = Http.token(%{"token" => "#{base_url}/api/token/"}, opts())

      assert_received {:request, ^setup_ref, conn}

      assert %Plug.Conn{
               method: "POST",
               request_path: "/api/token/",
               body_params: body_params
             } = conn

      assert %{
               "grant_type" => "password",
               "client_id" => "legacy_client_id",
               "client_secret" => "legacy_client_secret",
               "login" => "test",
               "password" => "test"
             } = Jason.decode!(body_params)
    end
  end

  describe "events/2" do
    test "successful response", context do
      %{bypass: bypass, base_url: base_url} = context

      setup_ref =
        setup_endpoint(
          bypass,
          status_code: 200,
          response_body: build_events_response(base_url)
        )

      assert %{
               "as_of" => _,
               "customer_id" => @customer_id,
               "events" => [%{"account" => @account_id}]
             } = Http.events(build_token_response(base_url), opts())

      assert_received {:request, ^setup_ref, conn}

      assert %Plug.Conn{
               method: "GET",
               request_path: "/api/customers/#{@customer_id}/feed",
               req_headers: req_headers
             } = conn

      assert {"authorization", "Bearer #{@access_token}"} in req_headers
    end
  end

  describe "feed/2" do
    test "successful response", context do
      %{bypass: bypass, base_url: base_url} = context

      setup_ref =
        setup_endpoint(
          bypass,
          status_code: 200,
          response_body: build_feed_response()
        )

      assert %{
               "data" => %{
                 "viewer" => %{
                   "savingsAccount" => %{
                     "feed" => [
                       %{
                         "__typename" => "AddToReserveEvent",
                         "detail" => _,
                         "id" => _,
                         "postDate" => _,
                         "title" => _
                       }
                     ],
                     "id" => _
                   }
                 }
               }
             } = Http.feed(build_token_response(base_url), opts())

      assert_received {:request, ^setup_ref, conn}

      assert %Plug.Conn{
               method: "POST",
               request_path: "/api/query",
               body_params: body_params,
               req_headers: req_headers
             } = conn

      assert %{
               "variables" => %{},
               "query" => @account_feed_query
             } = Jason.decode!(body_params)

      assert {"authorization", "Bearer #{@access_token}"} in req_headers
    end
  end

  defp build_discovery_app_response(base_url) do
    %{
      "scopes" => "#{base_url}/api/admin/scope",
      "creation" => "#{base_url}/api/creation",
      "change_password" => "#{base_url}/api/change-password",
      "smokejumper" => "#{base_url}/mobile/fire-station/smokejumper.json",
      "block" => "#{base_url}/api/admin/block",
      "lift" => "#{base_url}/api/proxy",
      "shard_mapping_id" => "#{base_url}/api/mapping/:kind/:id",
      "force_reset_password" => "#{base_url}/api/admin/force-reset-password",
      "revoke_token" => "#{base_url}/api/proxy",
      "userinfo" => "#{base_url}/api/userinfo",
      "reset_password" => "#{base_url}/api/proxy",
      "unblock" => "#{base_url}/api/admin/unblock",
      "shard_mapping_cnpj" => "#{base_url}/api/proxy",
      "shard_mapping_cpf" => "#{base_url}/api/mapping/cpf",
      "register_prospect" => "#{base_url}/api/proxy",
      "engage" => "#{base_url}/api/proxy",
      "creation_with_credentials" => "#{base_url}/api/proxy",
      "magnitude" => "#{base_url}/api/events",
      "revoke_all" => "#{base_url}/api/proxy",
      "user_update_credential" => "#{base_url}/api/proxy",
      "user_hypermedia" => "#{base_url}/api/admin/users/:id/hypermedia",
      "gen_certificate" => "#{base_url}/api/proxy",
      "email_verify" => "#{base_url}/api/proxy",
      "token" => "#{base_url}/api/token",
      "account_recovery" => "#{base_url}/api/proxy",
      "start_screen_v2" => "#{base_url}/api/proxy",
      "scopes_remove" => "#{base_url}/api/admin/scope/:admin-id",
      "approved_products" => "#{base_url}/api/proxy",
      "admin_revoke_all" => "#{base_url}/api/proxy",
      "faq" => %{
        "ios" => "#{base_url}/ios",
        "android" => "#{base_url}/android",
        "wp" => "#{base_url}/windows-phone"
      },
      "scopes_add" => "#{base_url}/api/admin/scope/:admin-id",
      "registration" => "#{base_url}/api/proxy",
      "global_services" => "#{base_url}/api/mapping/global-services",
      "start_screen" => "#{base_url}/api/proxy",
      "user_change_password" => "#{base_url}/api/user/:user-id/password",
      "account_recovery_token" => "#{base_url}/api/proxy",
      "user_status" => "#{base_url}/api/admin/user-status",
      "engage_and_create_credentials" => "#{base_url}/api/proxy"
    }
  end

  defp build_token_response(base_url) do
    %{
      "_links" => %{
        "customer" => %{
          "href" => "#{base_url}/api/customers/#{@customer_id}"
        },
        "ghostflame" => %{
          "href" => "#{base_url}/api/query"
        },
        "events" => %{
          "href" => "#{base_url}/api/customers/#{@customer_id}/feed"
        },
        "revoke_token" => %{
          "href" => "#{base_url}/api/revoke"
        },
        "bills_summary" => %{
          "href" => "#{base_url}/api/accounts/#{@account_id}/bills/summary"
        }
      },
      "access_token" => @access_token,
      "refresh_before" => "2021-09-30T01:14:44Z",
      "refresh_token" => "bar",
      "token_type" => "bearer"
    }
  end

  defp build_events_response(base_url) do
    %{
      "_links" => %{
        "updates" => %{
          "href" =>
            "#{base_url}/api/customers/#{@customer_id}/feed?feed-version=v1.5.1&since=2021-09-22T22:25:49.446Z"
        }
      },
      "as_of" => "2021-09-22T22:25:49.446Z",
      "customer_id" => @customer_id,
      "events" => [
        %{
          "_links" => %{
            "self" => %{
              "href" => "#{base_url}/api/transactions/0eff93b6-1c20-11ec-9621-0242ac130002"
            }
          },
          "account" => @account_id,
          "amount" => 3789,
          "amount_without_iof" => 3789,
          "category" => "transaction",
          "description" => "Ifood *Ifood",
          "details" => %{
            "status" => "unsettled",
            "subcategory" => "card_not_present"
          },
          "href" => "nuapp://transaction/0eff93b6-1c20-11ec-9621-0242ac130002",
          "id" => "0eff93b6-1c20-11ec-9621-0242ac130002",
          "source" => "upfront_national",
          "time" => "2021-09-22T22:25:48Z",
          "title" => "restaurante",
          "tokenized" => false
        }
      ]
    }
  end

  defp build_feed_response() do
    %{
      "data" => %{
        "viewer" => %{
          "savingsAccount" => %{
            "feed" => [
              %{
                "__typename" => "AddToReserveEvent",
                "detail" => "R$ 10,54",
                "id" => "00218ed0-1c20-11ec-9621-0242ac130002",
                "postDate" => "2021-09-22",
                "title" => "Saved money"
              }
            ],
            "id" => "5a39f618-fad9-4047-8881-143a8b8cb93f"
          }
        }
      }
    }
  end

  defp opts(),
    do: [username: "test", password: "test", cert_path: "/dev/null", key_path: "/dev/null"]
end
