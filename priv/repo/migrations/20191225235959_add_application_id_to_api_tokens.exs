defmodule LuppiterAuth.Repo.Migrations.AddApplicationIdToApiToken do
  use Ecto.Migration

  def change do
    alter table(:api_tokens) do
      add :application_id, :int, null: false
    end
  end
end
