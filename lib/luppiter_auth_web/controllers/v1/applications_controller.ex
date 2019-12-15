defmodule LuppiterAuthWeb.Api.V1.ApplicationsController do
  use LuppiterAuthWeb, :controller

  import Ecto.Query, only: [from: 2]

  alias LuppiterAuth.Repo
  alias LuppiterAuth.Schemas.{Application, UserIdentity}


  def get(conn, params) do
    conn |> json(Repo.one(from a in Application, where: a.uuid == ^params["app_id"], preload: [:owner]))
  end

  def list(conn, params) do
    case params["owner_id"] do
      nil      -> conn |> json([])
      owner_id ->
        case Repo.get_by(UserIdentity, uuid: owner_id) do
          nil   -> conn |> json([])
          owner -> conn |> json(Repo.all(from a in Application, where: a.owner_id == ^owner.id, preload: [:owner]))
        end
    end
  end
end
