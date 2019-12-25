defmodule LuppiterAuthWeb.Api.V1.AccountsControllerTest do
  use LuppiterAuthWeb.ConnCase
  alias LuppiterAuthWeb.Errors

  describe "create_with_google/2" do
    test "200 for valid id token", %{conn: conn} do
      with_mock LuppiterAuth.Providers.Google, [authenticate: fn(_) -> {:ok, build(:provider_user_info)} end] do
        username = Faker.Name.name
        response = conn
                   |> post(Routes.accounts_path conn, :create_by_google, %{username: username})
                   |> json_response(200)

        assert response != nil
        assert response["username"] == username
      end
    end

    test "400 for existing username", %{conn: conn} do
      with_mock LuppiterAuth.Providers.Google, [authenticate: fn(_) -> {:ok, build(:provider_user_info)} end] do
        identity = insert(:user_identity, %{username: Faker.Name.name})
        response = conn
                   |> post(Routes.accounts_path conn, :create_by_google, %{username: identity.username})
                   |> text_response(400)

        assert response == "duplicated_account"
      end
    end

    test "400 for invalid id token", %{conn: conn} do
      with_mock LuppiterAuth.Providers.Google, [authenticate: fn(_) -> {:error, "invalid"} end] do
        assert_raise Errors.InvalidProviderIdError, fn ->
          conn
            |> post(Routes.accounts_path conn, :create_by_google)
            |> text_response(400)
        end
      end
    end
  end
end
