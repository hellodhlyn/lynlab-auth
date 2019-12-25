defmodule LuppiterAuthWeb.Router do
  use LuppiterAuthWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LuppiterAuthWeb do
    get "/ping", PingController, :index
  end

  scope "/api", LuppiterAuthWeb.Api do
    pipe_through :api

    scope "/v1", V1 do
      post "/api_tokens/google", ApiTokensController, :create_by_google

      get "/applications", ApplicationsController, :list
      get "/applications/:app_id", ApplicationsController, :get
      post "/applications", ApplicationsController, :create
      post "/applications/authorizations", ApplicationsController, :authorize_application

      post "/accounts/google", AccountsController, :create_by_google
    end
  end

  def handle_errors(conn, %{kind: _, reason: reason, stack: _}) do
    conn
    |> put_resp_header("content-type", "application/json; charset=utf-8")
    |> send_resp(conn.status, Jason.encode!(%{error: reason.message}))
  end
end
