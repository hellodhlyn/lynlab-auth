defmodule LuppiterAuth.Schemas.ApiToken do
  use LuppiterAuth.Schema

  alias LuppiterAuth.Schemas.UserIdentity

  schema "api_tokens" do
    field :access_key, :string
    field :secret_key, :string
    field :expire_at,  :naive_datetime

    belongs_to :user_identity, UserIdentity

    timestamps()
  end
end
