defmodule LuppiterAuthWeb.PingController do
  use LuppiterAuthWeb, :controller

  def index(conn, _params) do
    text(conn, "pong")
  end
end
