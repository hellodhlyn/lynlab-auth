defmodule LuppiterAuth.Schemas.Application do
  use LuppiterAuth.Schema

  alias LuppiterAuth.Schemas.UserIdentity

  schema "applications" do
    field :uuid,         :string
    field :name,         :string
    field :redirect_url, :string

    belongs_to :owner, UserIdentity

    timestamps()
  end
end
