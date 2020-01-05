defmodule LuppiterAuthWeb.Api.V1.ApplicationsControllerTest do
  use LuppiterAuthWeb.ConnCase

  alias LuppiterAuth.Schemas.{ApiToken, Application, AppAuthorization}

  describe "get/2" do
    test "return application for valid app_id", %{conn: conn} do
      application = insert(:application)
      response = conn
                 |> get(Routes.applications_path(conn, :get, application.uuid))
                 |> json_response(200)

      assert response["app_id"] == application.uuid
    end

    test "return null for valid app_id", %{conn: conn} do
      response = conn
                 |> get(Routes.applications_path(conn, :get, Ecto.UUID.generate()))
                 |> json_response(200)

      assert response == nil
    end
  end

  describe "list/2" do
    test "return applications for valid owner_id", %{conn: conn} do
      owner = insert(:user_identity)
      Enum.map(1..3, fn _ -> insert(:application, %{owner: owner}) end)

      response = conn
                 |> get(Routes.applications_path(conn, :list, %{owner_id: owner.uuid}))
                 |> json_response(200)

      assert response |> length() == 3
      Enum.map(response, fn i -> assert i["owner"]["uuid"] == owner.uuid end)
    end

    test "return empty list for invalid owner_id", %{conn: conn} do
      response = conn
                 |> get(Routes.applications_path(conn, :list, %{owner_id: Ecto.UUID.generate()}))
                 |> json_response(200)

      assert response |> length() == 0
    end
  end

  describe "create/2" do
    test "success", %{conn: conn} do
      api_token = insert(:api_token)
      app_name = Faker.Company.name()
      redirect_url = Faker.Internet.domain_name()
      response = conn
        |> put_req_header("authorization", "Bearer " <> (api_token |> ApiToken.jwt_token()))
        |> post(Routes.applications_path(conn, :create, %{name: app_name, redirect_url: redirect_url}))
        |> json_response(200)

      # Check response
      assert response["name"] == app_name
      assert response["owner"]["uuid"] == api_token.user_identity.uuid

      # Check saved data
      application = Repo.get_by(Application, uuid: response["app_id"])
      assert application != nil
      assert application.name == app_name
      assert application.redirect_url == redirect_url
    end

    test "error for duplicated name", %{conn: conn} do
      application = insert(:application)
      conn
        |> put_req_header("authorization", "Bearer " <> (insert(:api_token) |> ApiToken.jwt_token()))
        |> post(Routes.applications_path(conn, :create, %{name: application.name}))
        |> json_response(400)
    end

    test "the name should be longer than 3 chars", %{conn: conn} do
      conn
        |> put_req_header("authorization", "Bearer " <> (insert(:api_token) |> ApiToken.jwt_token()))
        |> post(Routes.applications_path(conn, :create, %{name: "aaa"}))
        |> json_response(400)
    end
  end

  describe "get_app_authorization/2" do
    test "success: authorized", %{conn: conn} do
      api_token = insert(:api_token)
      insert(:app_authorization, %{application: api_token.application, user_identity: api_token.user_identity})

      response = conn
        |> put_req_header("authorization", "Bearer " <> (api_token |> ApiToken.jwt_token()))
        |> get(Routes.applications_path(conn, :get_app_authorization, api_token.application.uuid))
        |> json_response(200)

      assert response["authorized"] == true
    end
  end

  describe "create_app_authorization/2" do
    test "success", %{conn: conn} do
      api_token = insert(:api_token)
      application = insert(:application)

      conn
        |> put_req_header("authorization", "Bearer " <> (api_token |> ApiToken.jwt_token()))
        |> post(Routes.applications_path(conn, :create_app_authorization, application.uuid))
        |> json_response(200)

      auth = Repo.get_by(AppAuthorization, application_id: application.id, user_identity_id: api_token.user_identity.id)
      assert auth != nil
    end
  end
end
