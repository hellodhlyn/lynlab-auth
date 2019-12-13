defmodule LuppiterAuth.Schemas.UserAccountTest do
  use LuppiterAuth.DataCase

  alias LuppiterAuth.Schemas.UserAccount
  alias LuppiterAuth.Providers.UserInfo

  describe "create_from_user_info/2" do
    test "should success for fresh user" do
      provider_id = Ecto.UUID.generate()
      username    = Ecto.UUID.generate()


      assert {:ok, account} = %UserInfo{provider: "google", user_id: provider_id}
                              |> UserAccount.create_from_user_info(username)
      assert account.provider_id == provider_id
      assert account.user_identity.username == username
    end

    test "should fail if user account exists" do
      account = insert(:user_account)
      assert {:error, reason} = %UserInfo{provider: account.provider, user_id: account.provider_id}
                                |> UserAccount.create_from_user_info("dummy")
      assert reason == "duplicated_account"
    end

    test "should fail if username exists" do
      identity = insert(:user_identity)
      assert {:error, reason} = %UserInfo{provider: "google", user_id: Ecto.UUID.generate()}
                                |> UserAccount.create_from_user_info(identity.username)
      assert reason == "duplicated_account"
    end
  end
end
