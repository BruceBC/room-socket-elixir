# Utilize .env file
# Source: https://stackoverflow.com/questions/44949561/set-load-environment-variables-in-a-phoenix-app

defmodule Websocket.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    # TODO: Figure out how to set Mix.env when releasing using distillery
    IO.inspect "Current Environment: #{Mix.env()}"

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
