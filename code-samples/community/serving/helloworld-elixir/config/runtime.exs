import Config

if config_env() == :prod do
  port = String.to_integer(System.get_env("PORT") || "8080")

  unless port in 1..65_535 do
    raise "PORT must be between 1 and 65535"
  end

  config :hello, HelloWeb.Endpoint,
    server: true,
    http: [ip: {0, 0, 0, 0}, port: port]
end
