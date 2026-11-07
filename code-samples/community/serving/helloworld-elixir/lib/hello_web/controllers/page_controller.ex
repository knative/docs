defmodule HelloWeb.PageController do
  use HelloWeb, :controller

  # Never echo runtime secrets, release cookies, or arbitrary credentials.
  @visible_environment ~w(TARGET PORT K_SERVICE K_REVISION K_CONFIGURATION)

  def index(conn, _params) do
    env = System.get_env()

    conn
    |> put_view(HelloWeb.PageView)
    |> render("index.html",
      title: "Hello Knative",
      greeting: "Welcome to Knative and Elixir",
      target: Map.get(env, "TARGET"),
      env: Map.take(env, @visible_environment)
    )
  end
end
