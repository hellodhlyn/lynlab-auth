defmodule LuppiterAuth.Schemas.AppAuthorization do
  use LuppiterAuth.Schema

  alias LuppiterAuth.Schemas.{Application, UserIdentity}

  schema "app_authorizations" do
    belongs_to :application,   Application
    belongs_to :user_identity, UserIdentity

    timestamps()
  end
end
