defmodule LuppiterAuthWeb.AuthenticatorTest do
  use LuppiterAuthWeb.ConnCase

  import LuppiterAuthWeb.Authenticator

  alias LuppiterAuth.Schemas.ApiToken
  alias LuppiterAuthWeb.Errors.UnauthorizedError

  describe "authenticate/2" do
    test "success for valid api token", %{conn: conn} do
      api_token = insert(:api_token)
      identity = conn
                 |> put_req_header("authorization", "Bearer " <> (api_token |> ApiToken.jwt_token()))
                 |> authenticate()

      assert identity.id == api_token.user_identity.id
    end

    test "success for valid api token and app id", %{conn: conn} do
      api_token = insert(:api_token)
      identity = conn
                 |> put_req_header("authorization", "Bearer " <> (api_token |> ApiToken.jwt_token()))
                 |> authenticate(api_token.application.uuid)

      assert identity.id == api_token.user_identity.id
    end

    test "error if token not exists", %{conn: conn} do
      assert_raise UnauthorizedError, fn -> conn |> authenticate() end
    end

    test "error if invalid api token", %{conn: conn} do
      assert_raise UnauthorizedError, fn ->
        conn
        |> put_req_header("authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3Nfa2V5IjoibXlfYWNjZXNzX2tleSJ9.KeNn5GAd-OiD1JHWOOmgDt4BbTru7KLbvusIzhx6SQA")
        |> authenticate()
      end
    end

    test "error if api token has expired", %{conn: conn} do
      api_token = insert(:api_token, %{expire_at: NaiveDateTime.utc_now() |> NaiveDateTime.add(-1)})
      assert_raise UnauthorizedError, fn ->
        conn
        |> put_req_header("authorization", "Bearer " <> (api_token |> ApiToken.jwt_token()))
        |> authenticate()
      end
    end

    test "error if app id not matched", %{conn: conn} do
      api_token = insert(:api_token)
      assert_raise UnauthorizedError, fn ->
        conn
        |> put_req_header("authorization", "Bearer " <> (api_token |> ApiToken.jwt_token()))
        |> authenticate(Ecto.UUID.generate())
      end
    end
  end
end
