defmodule LuppiterAuth.Schemas.ApiToken do
  use LuppiterAuth.Schema

  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias LuppiterAuth.Repo
  alias LuppiterAuth.Schemas.{UserIdentity, Application}

  @type t :: %__MODULE__{
    :access_key => String.t(),
    :secret_key => String.t(),
    :expire_at => NaiveDateTime.t(),
  }

  schema "api_tokens" do
    field :access_key, :string
    field :secret_key, :string
    field :expire_at,  :naive_datetime

    belongs_to :user_identity, UserIdentity
    belongs_to :application, Application

    timestamps()
  end

  defimpl Jason.Encoder, for: [__MODULE__] do
    def encode(struct, opts) do
      Jason.Encode.map(%{
        access_key: struct.access_key,
        secret_key: struct.secret_key,
        expire_at: struct.expire_at,
      }, opts)
    end
  end

  def changeset(%__MODULE__{} = obj, params \\ %{}) do
    obj
    |> cast(params, [:access_key, :secret_key, :expire_at])
    |> unique_constraint(:access_key, name: :api_tokens_access_key)
  end

  @spec create!(UserIdentity.t(), Application.t()) :: t()
  def create!(user_identity, application) do
    expire_at = NaiveDateTime.utc_now() |> NaiveDateTime.add(7 * 24 * 60 * 60)

    %__MODULE__{}
    |> changeset(%{access_key: SecureRandom.hex(20), secret_key: SecureRandom.hex(20), expire_at: expire_at})
    |> Ecto.Changeset.put_assoc(:user_identity, user_identity)
    |> Ecto.Changeset.put_assoc(:application, application)
    |> Repo.insert()
  end

  @spec find_by_access_key(String.t(), list(atom())) :: t()
  def find_by_access_key(access_key, preload \\ []) do
    Repo.one(from t in __MODULE__, where: t.access_key == ^access_key, preload: ^preload)
  end

  @spec jwt_token(t) :: String.t()
  def jwt_token(api_token) do
    signer = Joken.Signer.create("HS256", api_token.secret_key)
    Joken.generate_and_sign!(%{}, %{access_key: api_token.access_key}, signer)
  end

  @spec verify_jwt_token(t, String.t()) :: boolean()
  def verify_jwt_token(api_token, jwt_token) do
    case Joken.verify(jwt_token, Joken.Signer.create("HS256", api_token.secret_key)) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  @spec expired?(t) :: boolean()
  def expired?(api_token) do
    (NaiveDateTime.utc_now() |> NaiveDateTime.compare(api_token.expire_at)) == :gt
  end
end
