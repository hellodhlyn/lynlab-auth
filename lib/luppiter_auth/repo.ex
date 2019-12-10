defmodule LuppiterAuth.Repo do
  use Ecto.Repo,
    otp_app: :luppiter_auth,
    adapter: Ecto.Adapters.Postgres
end
