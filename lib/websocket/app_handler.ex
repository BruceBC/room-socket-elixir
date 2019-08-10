defmodule Websocket.AppHandler do
  alias Websocket.Helpers.Jsn
  alias Websocket.Router
  alias Websocket.Response

  require Logger

  @behaviour :cowboy_websocket

  def init(req, _state) do
    opts = %{:idle_timeout => 10_000}
    {:cowboy_websocket, req, %{:client => req.pid, :origin => req.headers["origin"]}, opts}
  end

  def websocket_init(state) do
    trusted_origin = Application.fetch_env!(:websocket, :trusted_origin)

    authenticate(trusted_origin == state.origin, state)
  end

  def websocket_handle({:text, json}, state) do
    Jsn.to_json(json)
    |> inspect_json
    |> Router.App.route(state)
  end

  def websocket_info(:hardware_connected, state) do
    # Notify user if hardware is connected.
    Router.App.route(%{:type => "connected"}, state)
  end

  def websocket_info(:monitor_updated, state) do
    case state do
      %{:hardware_id => _hardware_id} ->
        Router.App.route(%{:type => "monitor"}, state)

      _ ->
        Response.reply("OK", 200, "Unkown", "unkown", state)
    end
  end

  def websocket_info(message, state) do
    {:reply, {:text, message}, state}
  end

  def terminate(_reason, _partial_req, state) do
    Logger.debug("terminated!")

    # Stop notifyng client
    stop_notifying_client(state)

    :ok
  end

  defp notify(client) do
    send(client, :hardware_connected)
    send(client, :monitor_updated)

    # Ideally, we could replace this timer with a pub/sub,
    # and allow the hardware to control when events are
    # pushed out.
    # Note:
    # This controls how frequently updates are sent out to the app client.
    # Therefore, sleep time should be less than idle time or it will cause
    # clien to constantly disconnect, since the client should send a ping
    # back every time it receives the updated monitor.
    :timer.sleep(100)

    notify(client)
  end

  # Ignore writing json to console for specific types, such as ping
  defp inspect_json(json) do
    case json do
      %{:type => "ping"} ->
        json

      _ ->
        json |> IO.inspect()
    end
  end

  defp authenticate(_trusted_origin = true, state) do
    Logger.debug("Connected")

    {:ok, pid} =
      Task.Supervisor.start_child(Websocket.TaskSupervisor, fn -> notify(state.client) end,
        restart: :transient
      )

    Router.App.route(%{:type => "ready"}, Map.merge(state, %{:task_pid => pid}))
  end

  defp authenticate(_trusted_origin = false, state) do
    Logger.debug("untrusted origin!")

    # Terminate
    {:reply, {:close, 1000, "Untrusted origin"}, state}
  end

  defp stop_notifying_client(_state = %{:task_pid => task_pid}),
    do: Task.Supervisor.terminate_child(Websocket.TaskSupervisor, task_pid)

  defp stop_notifying_client(_state), do: nil
end
