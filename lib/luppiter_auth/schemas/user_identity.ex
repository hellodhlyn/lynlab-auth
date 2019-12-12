defmodule LuppiterAuth.Schemas.UserIdentity do
  use LuppiterAuth.Schema

  alias LuppiterAuth.Repo
  alias LuppiterAuth.Schemas.UserAccount

  @derive {Jason.Encoder, only: [:uuid, :username, :email, :created_at]}
  schema "user_identities" do
    field :uuid,     :string
    field :username, :string
    field :email,    :string

    has_many :user_accounts, UserAccount

    timestamps()
  end

  @spec create_from_user_info!(LuppiterAuth.Providers.UserInfo.t(), String.t()) :: __MODULE__
  def create_from_user_info!(user_info, username) do
    Repo.insert!(%__MODULE__{uuid: Ecto.UUID.generate(), username: username, email: user_info.email})
  end

  @spec exists_by?(Keyword.t()) :: boolean()
  def exists_by?(query) do
    Repo.get_by(__MODULE__, query) != nil
  end
end
