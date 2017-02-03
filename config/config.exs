# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :broken_links, BrokenLinks.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9ckm5a3zusDPQ3ALJN+BvhUMXfS881QZdxgMBLjLYDr8poO1gtstYA6bE45bkT1D",
  render_errors: [view: BrokenLinks.ErrorView, accepts: ~w(html json)],
  pubsub: [name: BrokenLinks.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
