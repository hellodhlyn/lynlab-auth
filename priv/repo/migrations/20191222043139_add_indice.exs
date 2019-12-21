defmodule LuppiterAuth.Repo.Migrations.AddIndice do
  use Ecto.Migration

  def change do
    drop index(:user_identities, [:uuid])
    create unique_index(:user_identities, [:uuid])
    create unique_index(:user_identities, [:username])
    create unique_index(:user_identities, [:email])

    drop index(:user_accounts, [:provider, :provider_id])
    create unique_index(:user_accounts, [:provider, :provider_id])

    drop index(:applications, [:uuid])
    create unique_index(:applications, [:uuid])
    create unique_index(:applications, [:name])

    create unique_index(:app_authorizations, [:user_identity_id, :application_id])

    drop index(:api_tokens, [:access_key])
    create unique_index(:api_tokens, [:access_key])
  end
end
