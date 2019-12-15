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

  defimpl Jason.Encoder, for: [__MODULE__] do
    def encode(struct, opts) do
      Jason.Encode.map(%{
        app_id: struct.uuid,
        name: struct.name,
        created_at: struct.created_at,
        owner: %{uuid: struct.owner.uuid, username: struct.owner.username},
      }, opts)
    end
  end
end
