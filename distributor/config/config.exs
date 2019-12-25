# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

#config :distributor,
#  ecto_repos: [Distributor.Repo]

# Configures the endpoint
config :distributor, DistributorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Ap1mcrrbYqxfnaAhJR+7mttfFp4yW9mU1jvN6L5DZT1Y9MoJtdKxlM4Ee5aP8hmF",
  render_errors: [view: DistributorWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Distributor.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
