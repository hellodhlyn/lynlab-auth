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
      post "/accounts/google", AccountsController, :create_by_google
    end
  end
end
