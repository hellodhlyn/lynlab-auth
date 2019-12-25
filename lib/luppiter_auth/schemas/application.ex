defmodule LuppiterAuth.Schemas.Application do
  use LuppiterAuth.Schema

  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias LuppiterAuth.Repo
  alias LuppiterAuth.Schemas.UserIdentity

  @type t :: %__MODULE__{
    :uuid => String.t(),
    :name => String.t(),
    :redirect_url => String.t(),
    :owner => UserIdentity.t(),
  }

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

  def changeset(%__MODULE__{} = obj, params \\ %{}) do
    obj
    |> cast(params, [:uuid, :name, :redirect_url])
    |> validate_length(:name, min: 4)
    |> unique_constraint(:uuid, name: :applications_uuid_index)
    |> unique_constraint(:name, name: :applications_name_index)
  end

  @spec find_by_uuid(String.t(), list(atom())) :: t()
  def find_by_uuid(uuid, preload \\ []) do
    Repo.one(from a in __MODULE__, where: a.uuid == ^uuid, preload: ^preload)
  end
end
