defmodule LuppiterAuthWeb.Api.V1.ApiTokensController do
  use LuppiterAuthWeb, :controller

  require Logger

  alias LuppiterAuth.Schemas.{UserAccount, Application, ApiToken, AppAuthorization}
  alias LuppiterAuthWeb.Errors

  # POST /v1/api_tokens/google
  def create_by_google(conn, params) do
    case LuppiterAuth.Providers.Google.authenticate(params["id_token"]) do
      {:error, reason} ->
        Logger.warn("Failed to get Google user info: #{reason}")
        raise Errors.InvalidProviderIdError

      {:ok, info} ->
        case UserAccount.find_by_provider_id("google", info.user_id, [:user_identity]) do
          nil -> raise Errors.UnauthorizedError
          account ->
            app = Application.find_by_uuid(params["app_id"])
            if AppAuthorization.find_by_user_identity_and_application(account.user_identity, app) != nil do
              {:ok, token} = ApiToken.create!(account.user_identity, app)
              conn |> json(token)
            else
              raise Errors.UnauthorizedApplicationError
            end
        end
    end
  end
end
