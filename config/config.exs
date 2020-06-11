# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :relay_ui,
  ecto_repos: [RelayUi.Repo]

# Configures the endpoint
config :relay_ui, RelayUiWeb.Endpoint,
  url: [host: "gashog.kbs.msu.edu", port: 4000],
  secret_key_base: "r8DdBy6tjBFiQooYjCxccXkivh16EivmR/EoHlEyY7N6jDMX4G4BkoBbRcpQGs0t",
  render_errors: [view: RelayUiWeb.ErrorView, accepts: ~w(html json)],
  live_view: [signing_salt: "WIyhMrwgbsn0hnvwkuqcGaodOsxadvGW"],
  pubsub_server: RelayUi.PubSub

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
