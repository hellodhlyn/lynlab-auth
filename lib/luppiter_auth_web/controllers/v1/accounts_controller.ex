defmodule LuppiterAuthWeb.Api.V1.AccountsController do
  use LuppiterAuthWeb, :controller

  require Logger

  alias LuppiterAuth.Schemas.UserAccount

  def create_by_google(conn, params) do
    case LuppiterAuth.Providers.Google.authenticate(params["idToken"]) do
      {:error, reason} ->
        Logger.warn("Failed to get Google user info: #{reason}")
        conn |> put_status(400) |> text("")

      {:ok, info} ->
        case UserAccount.create_from_user_info(info, params["username"]) do
          {:error, reason} -> nil  # TODO implement
          {:ok, account}   -> nil  # TODO implement
        end
        text(conn, "OK")
    end
  end
end
