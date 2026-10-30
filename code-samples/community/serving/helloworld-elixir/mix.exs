defmodule Hello.MixProject do
  use Mix.Project

  def project do
    [
      app: :hello,
      version: "0.1.0",
      elixir: "~> 1.20",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [mod: {Hello.Application, []}, extra_applications: [:logger, :runtime_tools]]
  end

  defp deps do
    [
      {:phoenix, "~> 1.8.16"},
      {:phoenix_html, "~> 4.3"},
      {:phoenix_view, "~> 2.0"},
      {:bandit, "~> 1.13"},
      {:jason, "~> 1.4"}
    ]
  end
end
