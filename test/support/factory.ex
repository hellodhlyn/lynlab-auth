defmodule LuppiterAuth.Factory do
  use ExMachina.Ecto, repo: LuppiterAuth.Repo

  alias LuppiterAuth.Schemas

  ### Ecto schemas

  def api_token_factory do
    %Schemas.ApiToken{
      access_key:    SecureRandom.hex(20),
      secret_key:    SecureRandom.hex(20),
      expire_at:     DateTime.utc_now() |> Date.add(7),
      user_identity: build(:user_identity),
    }
  end

  def app_authorization_factory do
    %Schemas.AppAuthorization{
      application:   build(:application),
      user_identity: build(:user_identity),
    }
  end

  def application_factory do
    %Schemas.Application{
      uuid:  Ecto.UUID.generate(),
      name:  Faker.Name.name(),
      owner: build(:user_identity),
    }
  end

  def user_account_factory do
    %Schemas.UserAccount{
      provider:      "google",
      provider_id:   Ecto.UUID.generate(),
      user_identity: build(:user_identity),
    }
  end

  def user_identity_factory do
    %Schemas.UserIdentity{
      uuid:     Ecto.UUID.generate(),
      username: Faker.Name.name(),
      email:    Faker.Internet.email(),
    }
  end

  ### Non-Ecto structs
  def provider_user_info_factory do
    %LuppiterAuth.Providers.UserInfo{
      provider:  "google",
      user_id:   Ecto.UUID.generate(),
      email:     Faker.Internet.email(),
      expire_at: DateTime.utc_now() |> Date.add(7),
    }
  end
end
