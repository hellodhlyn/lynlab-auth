defmodule LuppiterAuth.Schemas.UserIdentity do
  use LuppiterAuth.Schema

  alias LuppiterAuth.Schemas.UserAccount

  schema "user_identities" do
    field :uuid,     :string
    field :username, :string
    field :email,    :string

    has_many :user_accounts, UserAccount

    timestamps()
  end
end
