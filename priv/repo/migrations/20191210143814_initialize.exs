defmodule LuppiterAuth.Repo.Migrations.Initialize do
  use Ecto.Migration

  def change do
    create table(:user_identities) do
      add :uuid,     :string, null: false, size: 36
      add :username, :string, null: false, size: 40
      add :email,    :string

      timestamps()
    end

    create index(:user_identities, [:uuid])

    create table(:user_accounts) do
      add :user_identity_id, :integer, null: false
      add :provider,         :string,  null: false, size: 40
      add :provider_id,      :string,  null: false

      timestamps()
    end

    create index(:user_accounts, [:user_identity_id])
    create index(:user_accounts, [:provider, :provider_id])

    create table(:applications) do
      add :uuid,         :string, null: false, size: 36
      add :name,         :string, null: false, size: 40
      add :owner_id,     :integer, null: false
      add :redirect_url, :string

      timestamps()
    end

    create index(:applications, [:uuid])

    create table(:app_authorizations) do
      add :user_identity_id, :integer, null: false
      add :application_id,   :integer, null: false

      timestamps()
    end

    create index(:app_authorizations, [:user_identity_id])
    create index(:app_authorizations, [:application_id])

    create table(:api_tokens) do
      add :access_key,       :string,  null: false, size: 40
      add :secret_key,       :string,  null: false, size: 40
      add :user_identity_id, :integer, null: false
      add :expire_at,        :naive_datetime

      timestamps()
    end

    create index(:api_tokens, [:access_key])
    create index(:api_tokens, [:user_identity_id])
  end
end
