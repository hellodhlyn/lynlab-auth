defmodule LuppiterAuth.Schemas.UserAccount do
  use LuppiterAuth.Schema

  alias LuppiterAuth.Schemas.UserIdentity

  schema "user_accounts" do
    field :provider,    :string
    field :provider_id, :string
    
    belongs_to :user_identitey, UserIdentity

    timestamps()
  end
end
