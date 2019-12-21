defmodule LuppiterAuth.Schemas.ApiTokenTest do
  use LuppiterAuth.DataCase

  alias LuppiterAuth.Schemas.ApiToken

  describe "jwt_token/1" do
    api_token = build(:api_token, %{access_key: "my_access_key", secret_key: "my_secret_key"})
    assert api_token |> ApiToken.jwt_token() == "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3Nfa2V5IjoibXlfYWNjZXNzX2tleSJ9.-Z3zfVLWm2rm4O9WNKi3I1PmZY04-3TvAHsih2Ndlhw"
  end
end
