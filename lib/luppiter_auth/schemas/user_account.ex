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
          :: {:ok, UserAccount} | {:error, String.t()}
  def create_from_user_info(user_info, username) do
    account_exists?(user_info.provider, user_info.user_id) or username_exists?(username)
    |> case do
      true  -> {:error, "duplicated_account"}
      false -> {:ok, nil}  # TODO implement
    end
  end

  @spec account_exists?(String.t(), String.t()) :: boolean()
  defp account_exists?(provider, provider_id) do
    Repo.get_by(__MODULE__, provider: provider, provider_id: provider_id) != nil
  end

  @spec username_exists?(String.t()) :: boolean()
  defp username_exists?(username) do
    Repo.get_by(UserIdentity, username: username) != nil
  end
end
