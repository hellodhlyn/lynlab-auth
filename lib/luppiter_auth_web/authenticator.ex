defmodule LuppiterAuthWeb.Authenticator do
  import Plug.Conn
  import Ecto.Query, only: [from: 2]

  alias LuppiterAuth.Repo
  alias LuppiterAuth.Schemas.ApiToken
  alias LuppiterAuthWeb.Errors.UnauthorizedError

  def authenticate(conn) do
    authorization = conn |> get_req_header("authorization") |> List.first()
    if authorization == nil do
      raise UnauthorizedError
    end

    bearer_token = authorization |> String.split() |> List.last()

    api_token = case Joken.peek_claims(bearer_token) do
      {:error, _} -> raise UnauthorizedError
      {:ok, claim} -> Repo.one(from t in ApiToken, where: t.access_key == ^claim["access_key"], preload: [:user_identity])
    end
    if api_token == nil or api_token |> ApiToken.expired?() do
      raise UnauthorizedError
    end

    case api_token |> ApiToken.verify_jwt_token(bearer_token) do
      false -> raise UnauthorizedError
      true -> api_token.user_identity
    end
  end
end
