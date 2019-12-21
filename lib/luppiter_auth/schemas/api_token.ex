defmodule LuppiterAuth.Schemas.ApiToken do
  use LuppiterAuth.Schema

  alias LuppiterAuth.Schemas.UserIdentity

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

    timestamps()
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
