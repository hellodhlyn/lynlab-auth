defmodule LuppiterAuthWeb.Router do
  use LuppiterAuthWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", LuppiterAuthWeb do
    pipe_through :api
  end
end
