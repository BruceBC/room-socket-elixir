defmodule Websocket.MixProject do
  use Mix.Project

  def project do
    [
      app: :websocket,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Websocket.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:distillery, "~> 2.1"},
      {:plug_cowboy, "~> 2.1"},
      {:poison, "~> 4.0"},
      {:monitor, git: "https://github.com/brucebc/room-monitor-elixir.git", tag: "v1.0.0"}
    ]
  end
end
