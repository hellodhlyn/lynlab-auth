defmodule LuppiterAuthWeb.Api.V1.ApplicationsController do
  use LuppiterAuthWeb, :controller

  alias LuppiterAuth.Repo
  alias LuppiterAuth.Schemas.{Application, UserIdentity}

  # GET /v1/applications/:app_id
  def get(conn, params) do
    conn |> json(Repo.one(from a in Application, where: a.uuid == ^params["app_id"], preload: [:owner]))
  end

  # GET /v1/applications
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

  # POST /v1/applications
  def create(conn, params) do
    %Application{}
    |> Application.changeset(%{uuid: Ecto.UUID.generate(), name: params["name"], redirect_url: params["redirect_url"]})
    |> Ecto.Changeset.put_assoc(:owner, authenticate(conn))
    |> Repo.insert()
    |> case do
      {:error, _} -> conn |> put_status(400) |> json(nil)
      {:ok, app}  -> conn |> json(app)
    end
  end
end
