# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures repo
config :luppiter_auth, LuppiterAuth.Repo, migration_timestamps: [inserted_at: :created_at]
config :luppiter_auth,
  ecto_repos: [LuppiterAuth.Repo]

# Configures the endpoint
config :luppiter_auth, LuppiterAuthWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "BQ7HkKPN+xASw5qPNV2DASPXu+40ikcn4QsAsOyCcRs/t9a6M0SoWBuxmTQDsIIB",
  render_errors: [view: LuppiterAuthWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: LuppiterAuth.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
