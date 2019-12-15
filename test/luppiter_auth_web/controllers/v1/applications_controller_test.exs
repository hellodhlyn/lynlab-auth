defmodule LuppiterAuthWeb.Api.V1.ApplicationsControllerTest do
  use LuppiterAuthWeb.ConnCase

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
end
