# Utilize .env file
# Source: https://stackoverflow.com/questions/44949561/set-load-environment-variables-in-a-phoenix-app

defmodule Websocket.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    # Use the user's default ip for dev
    if Mix.env() == :dev && !File.exists?(".env") do
      require Logger

      Logger.warn(
        ".env file not found for environment :dev, using your default ip address instead."
      )

      Application.put_env(
        :websocket,
        :trusted_origin,
        "wss://#{Websocket.Helpers.System.ip(:find)}"
      )
    else
      IO.inspect("Using .env")
    end

    children = [
      worker(Websocket.HardwareStore, [[]]),
      {Task.Supervisor, name: Websocket.TaskSupervisor},
      Plug.Cowboy.child_spec(
        scheme: :https,
        plug: Websocket.Router,
        options: Application.fetch_env!(:cowboy, :https)
      )
    ]

    opts = [strategy: :one_for_one, name: Websocket.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
