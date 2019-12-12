defmodule LuppiterAuth.Schemas.UserAccount do
  use LuppiterAuth.Schema

  alias LuppiterAuth.Repo
  alias LuppiterAuth.Schemas.UserIdentity

  schema "user_accounts" do
    field :provider,    :string
    field :provider_id, :string
    
    belongs_to :user_identity, UserIdentity

    timestamps()
  end

  @spec create_from_user_info(LuppiterAuth.Providers.UserInfo.t(), String.t())
          :: {:ok, __MODULE__} | {:error, String.t()}
  def create_from_user_info(user_info, username) do
    (exists_by?(provider: user_info.provider, provider_id: user_info.user_id) or UserIdentity.exists_by?(username: username))
    |> case do
      true  -> {:error, "duplicated_account"}
      false ->
        Repo.transaction(fn ->
          Repo.insert!(%__MODULE__{
            provider:      user_info.provider,
            provider_id:   user_info.user_id,
            user_identity: UserIdentity.create_from_user_info!(user_info, username),
          })
        end)
    end
  end

  @spec exists_by?(Keyword.t()) :: boolean()
  def exists_by?(query) do
    Repo.get_by(__MODULE__, query) != nil
  end
end
