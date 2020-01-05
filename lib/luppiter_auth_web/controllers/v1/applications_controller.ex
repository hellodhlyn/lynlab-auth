defmodule LuppiterAuthWeb.Api.V1.ApplicationsController do
  use LuppiterAuthWeb, :controller

  alias LuppiterAuth.Repo
  alias LuppiterAuth.Schemas.{AppAuthorization, Application, UserIdentity}

  # GET /v1/applications/:app_id
  def get(conn, params) do
    conn |> json(Application.find_by_uuid(params["app_id"], [:owner]))
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

  # GET /v1/applications/:app_id/authorization
  def get_app_authorization(conn, params) do
    identity = authenticate(conn)
    app = Application.find_by_uuid(params["app_id"])
    authorized = (
      Repo.one(
        from a in AppAuthorization,
        where: a.application_id == ^app.id and a.user_identity_id == ^identity.id
      ) != nil
    )

    conn |> json(%{authorized: authorized})
  end

  # POST /v1/applications/:app_id/authorization
  def create_app_authorization(conn, params) do
    %AppAuthorization{}
    |> AppAuthorization.changeset(%{})
    |> Ecto.Changeset.put_assoc(:application, Application.find_by_uuid(params["app_id"]))
    |> Ecto.Changeset.put_assoc(:user_identity, authenticate(conn))
    |> Repo.insert()
    |> case do
      {:error, _} -> conn |> put_status(400) |> json(nil)
      {:ok, _}  -> conn |> json(nil)
    end
  end
end
