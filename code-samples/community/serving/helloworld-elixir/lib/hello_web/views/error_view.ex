defmodule HelloWeb.ErrorView do
  use HelloWeb, :view

  def render(template, _assigns) do
    case Integer.parse(template) do
      {status, _format} -> Plug.Conn.Status.reason_phrase(status)
      :error -> "Internal Server Error"
    end
  end
end
