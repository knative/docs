defmodule HelloWeb.PageController do
  use HelloWeb, :controller

  def index(conn, params) do
    env = System.get_env()
    target = Map.get(env, "TARGET")

    render conn, "index.html",
        title: "Hello Knative",
        greeting: "Welcome to Knative and Elixir",
        target: target,
        env: env
  end
end
