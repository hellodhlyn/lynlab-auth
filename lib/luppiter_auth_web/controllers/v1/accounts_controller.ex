defmodule LuppiterAuthWeb.Api.V1.AccountsController do
  use LuppiterAuthWeb, :controller

  require Logger

  alias LuppiterAuth.Schemas.UserAccount
  alias LuppiterAuthWeb.Errors

  def create_by_google(conn, params) do
    case LuppiterAuth.Providers.Google.authenticate(params["id_token"]) do
      {:error, reason} ->
        Logger.warn("Failed to get Google user info: #{reason}")
        raise Errors.InvalidProviderIdError

      {:ok, info} ->
        case UserAccount.create_from_user_info(info, params["username"]) do
          {:error, reason} -> conn |> put_status(400) |> text(reason)
          {:ok, account}   -> conn |> json(account.user_identity)
        end
    end
  end
end
