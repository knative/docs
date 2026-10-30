defmodule HelloWeb do
  @moduledoc "Shared helpers for this small Phoenix application."

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html],
        layouts: [html: {HelloWeb.LayoutView, :app}]

      import Plug.Conn
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/hello_web/templates",
        namespace: HelloWeb

      import Phoenix.HTML
      import Phoenix.VerifiedRoutes, only: [static_path: 2]
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  defmacro __using__(which) when is_atom(which), do: apply(__MODULE__, which, [])
end
