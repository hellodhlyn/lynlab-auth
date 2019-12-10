defmodule LuppiterAuthWeb.PingControllerTest do
  use LuppiterAuthWeb.ConnCase

  describe "index/2" do
    test "index/2 respond pong", %{conn: conn} do
      response = conn
        |> get(Routes.ping_path conn, :index)
        |> text_response(200)

      assert response == "pong"
    end
  end
end
