import Config

config :hello, HelloWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [formats: [html: HelloWeb.ErrorView], layout: false],
  pubsub_server: Hello.PubSub,
  # Demonstration signing key only; change this for production.
  secret_key_base: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"

config :phoenix, :json_library, Jason
config :logger, :default_formatter, format: "$time $metadata[$level] $message\n"

import_config "#{config_env()}.exs"
