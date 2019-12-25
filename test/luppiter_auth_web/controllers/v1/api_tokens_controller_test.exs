defmodule LuppiterAuthWeb.Api.V1.ApiTokensControllerTest do
  use LuppiterAuthWeb.ConnCase

  alias LuppiterAuth.Schemas.{ApiToken}
  alias LuppiterAuthWeb.Errors

  describe "create_by_google/2" do
    test "success", %{conn: conn} do
      app = insert(:application)

      prov_info = build(:provider_user_info, %{provider: "google"})
      user_identity = insert(:user_identity)
      insert(:user_account, %{user_identity: user_identity, provider: "google", provider_id: prov_info.user_id})
      insert(:app_authorization, %{application: app, user_identity: user_identity})

      api_token = insert(:api_token, %{application: app, user_identity: user_identity})

      with_mock LuppiterAuth.Providers.Google, [authenticate: fn(_) -> {:ok, prov_info} end] do
        response = conn
          |> put_req_header("authorization", "Bearer " <> (api_token |> ApiToken.jwt_token()))
          |> post(Routes.api_tokens_path conn, :create_by_google, %{app_id: app.uuid})
          |> json_response(200)
        assert response != nil

        api_token = ApiToken.find_by_access_key(response["access_key"], [:user_identity, :application])
        assert api_token != nil
        assert api_token.user_identity.id == user_identity.id
        assert api_token.application.id == app.id
      end
    end

    test "failed for unauthorized apps", %{conn: conn} do
      app = insert(:application)

      prov_info = build(:provider_user_info, %{provider: "google"})
      user_identity = insert(:user_identity)
      insert(:user_account, %{user_identity: user_identity, provider: "google", provider_id: prov_info.user_id})

      api_token = insert(:api_token, %{application: app, user_identity: user_identity})

      with_mock LuppiterAuth.Providers.Google, [authenticate: fn(_) -> {:ok, prov_info} end] do
        assert_raise Errors.UnauthorizedApplicationError, fn ->
          conn
            |> put_req_header("authorization", "Bearer " <> (api_token |> ApiToken.jwt_token()))
            |> post(Routes.api_tokens_path conn, :create_by_google, %{app_id: app.uuid})
            |> json_response(200)
        end
      end
    end
  end
end
