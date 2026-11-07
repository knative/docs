import Config

config :hello, HelloWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  debug_errors: true,
  check_origin: false

config :logger, :default_formatter, format: "[$level] $message\n"
