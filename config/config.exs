# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :bonbon,
    ecto_repos: [Bonbon.Repo]

# Configures the endpoint
config :bonbon, Bonbon.Endpoint,
    url: [host: "localhost"],
    secret_key_base: "VxNl1rRLfOSKC8IqnMeevrJi5d8HZJmEpXbQ3FS8oTdNym03CMDzfV2swzvA8QQx",
    render_errors: [view: Bonbon.ErrorView, accepts: ~w(json)],
    pubsub: [name: Bonbon.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
    format: "$time $metadata[$level] $message\n",
    metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
