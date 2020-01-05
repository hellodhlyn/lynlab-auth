defmodule LuppiterAuthWeb.Authenticator do
  import Plug.Conn

  alias LuppiterAuth.Schemas.ApiToken
  alias LuppiterAuthWeb.Errors.UnauthorizedError

  def authenticate(conn, app_id \\ nil) do
    authorization = conn |> get_req_header("authorization") |> List.first()
    if authorization == nil do
      raise UnauthorizedError
    end

    bearer_token = authorization |> String.split() |> List.last()

    api_token = case Joken.peek_claims(bearer_token) do
      {:error, _} -> raise UnauthorizedError
      {:ok, claim} ->
        if claim["access_key"] == nil do
          raise UnauthorizedError
        end
        ApiToken.find_by_access_key(claim["access_key"], [:user_identity, :application])
    end
    if api_token == nil or api_token |> ApiToken.expired?() do
      raise UnauthorizedError
    end

    if ApiToken.verify_jwt_token(api_token, bearer_token) and (app_id == nil or api_token.application.uuid == app_id) do
      api_token.user_identity
    else
      raise UnauthorizedError
    end
  end
end
