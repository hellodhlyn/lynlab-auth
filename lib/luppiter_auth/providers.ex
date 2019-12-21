defmodule LuppiterAuth.Providers.UserInfo do
  @type t :: %__MODULE__{
    :provider  => String.t(),
    :user_id   => String.t(),
    :email     => String.t(),
    :expire_at => NaiveDateTime.t(),
  }

  @derive Jason.Encoder
  defstruct [:provider, :user_id, :email, :expire_at]
end
