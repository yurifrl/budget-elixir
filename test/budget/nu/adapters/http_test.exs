defmodule Budget.Nu.Adapters.HttpTest do
  use Budget.HttpCase, async: true

  alias Budget.Nu.Adapters.Http
  alias Budget.Nu.Adapters.ResponseMock

  setup do
    opts = options()
    username = Keyword.fetch!(opts, :username)
    password = Keyword.fetch!(opts, :password)
    cert_path = Keyword.fetch!(opts, :cert_path)
    %{username: username, password: password, cert_path: cert_path}
  end

  describe "discovery/1" do
    test "successful response", context do
      %{bypass: bypass, base_url: base_url} = context
      # base_url = Keyword.fetch!(options(), :base_url)

      setup_ref =
        setup_endpoint(
          bypass,
          status_code: 200,
          response_body: build_discovery_app_response(base_url)
        )

      assert %{} = Http.discovery_app(base_url: base_url)

      assert_received {:request, ^setup_ref, conn}

      assert %Plug.Conn{
               method: "GET",
               request_path: "/api/app/discovery",
               req_headers: req_headers,
               body_params: body_params
             } = conn

      Jason.decode!(body_params)
      |> IO.inspect(label: "====>>>> 30 ", pretty: true, limit: :infinity)

      assert %{} = Jason.decode!(body_params)

      assert {"content-type", "application/json"} in req_headers
      assert {"X-Correlation-Id", ""} in req_headers
      assert {"User-Agent", "BudgetElixir/1.0.0"} in req_headers
    end
  end

  defp options, do: Application.fetch_env!(:budget, Budget.Nu.Adapters.Http)

  defp build_discovery_response(base_url) do
    %{
      "register_prospect_savings_web" => "#{base_url}/api/proxy",
      "register_prospect_savings_mgm" => "#{base_url}/api/proxy",
      "pusher_auth_channel" => "#{base_url}/api/proxy",
      "register_prospect_debit" => "#{base_url}/api/proxy",
      "reset_password" => "#{base_url}/api/proxy",
      "business_card_waitlist" => "#{base_url}/api/proxy",
      "register_prospect" => "#{base_url}/api/proxy",
      "register_prospect_savings_request_money" => "#{base_url}/api/proxy",
      "register_prospect_global_web" => "#{base_url}/api/proxy",
      "register_prospect_c" => "#{base_url}/api/proxy",
      "request_password_reset" => "#{base_url}/api/proxy",
      "auth_gen_certificates" => "#{base_url}/api/proxy",
      "login" => "#{base_url}/api/proxy",
      "email_verify" => "#{base_url}/api/proxy",
      "ultraviolet_waitlist" => "#{base_url}/api/proxy",
      "auth_device_resend_code" => "#{base_url}/api/proxy",
      "msat" => "#{base_url}/api/proxy"
    }
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
end
