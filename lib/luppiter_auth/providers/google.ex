defmodule LuppiterAuth.Providers.Google do
  alias GoogleApi.OAuth2.V2

  @connection V2.Connection.new

  @spec authenticate(String.t()) :: {:ok, LuppiterAuth.Providers.UserInfo.t()}, {:error, String.t()}
  def authenticate(token) do
    case V2.Api.Default.oauth2_tokeninfo(@connection, key: System.get_env("GOOGLE_CLIENT_ID"), id_token: token) do
      {:ok, info} -> {:ok, %LuppiterAuth.Providers.UserInfo{
        :provider  => "google",
        :user_id   => info.user_id,
        :email     => if(info.verified_email, do: info.email, else: nil), 
        :expire_at => DateTime.from_unix!((DateTime.utc_now() |> DateTime.to_unix()) + info.expires_in),
      }}
      {:error, reason} -> {:error, reason.body}
    end
  end
end
