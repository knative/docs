defmodule HelloWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :hello

  plug(Plug.Static,
    at: "/",
    from: :hello,
    gzip: true,
    only: ~w(css favicon.ico robots.txt)
  )

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])
  plug(Plug.Head)

  plug(Plug.Session,
    store: :cookie,
    key: "_hello_key",
    signing_salt: "M0cGJtXU"
  )

  plug(HelloWeb.Router)
end
