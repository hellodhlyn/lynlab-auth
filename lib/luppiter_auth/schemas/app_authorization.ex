defmodule LuppiterAuth.Schemas.AppAuthorization do
  use LuppiterAuth.Schema

  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias LuppiterAuth.Repo
  alias LuppiterAuth.Schemas.{Application, UserIdentity}

  schema "app_authorizations" do
    belongs_to :application,   Application
    belongs_to :user_identity, UserIdentity

    timestamps()
  end

  def changeset(%__MODULE__{} = obj, params \\ %{}) do
    obj |> cast(params, [])
  end

  def find_by_user_identity_and_application(user_identity, application, preload \\ []) do
    Repo.one(
      from a in __MODULE__,
      where: a.user_identity_id == ^user_identity.id and a.application_id == ^application.id,
      preload: ^preload
    )
  end
end
