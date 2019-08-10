defmodule Websocket.Router.App do
  alias Websocket.{ HardwareStore, Response }

  @response_types %{
    :ready               => "ready",
    :paired              => "paired",              # Hardware id set
    :max                 => "max",                 # Max proximity value set
    :monitor             => "monitor",             # Get Monitor.State
    :connected           => "connected",           # Hardware connected
    :disconnected        => "disconnected",        # Hardware disconnected
    :process_not_started => "process_not_started", # Hardware has not connected yet, try again
    :pong                => "pong",
    :error               => "error"
  }

  def route(_json = %{:type => "ready"}, state) do
    Response.reply("Ready", 200, "Connected to server.", @response_types.ready, state)
  end

  def route(_json = %{:type => "pair"}, state = %{ :hardware_id => _hardware_id}) do
    Response.error("Unprocessable Entity", 422, "Already paired.", @response_types.error, state)
  end

  def route(json = %{:type => "pair"}, state) do
    state = Map.merge(
        state,
        %{:hardware_id => json.hardware_id}
      )

    Response.reply("Created", 201, "Paired successfuly.", @response_types.paired, state)
  end

  def route(_json = %{:type => "monitor"}, state = %{ :hardware_id => hardware_id }) do
    HardwareStore.get(hardware_id)
    |> get_monitor_pid
    |> get_monitor(state)
  end

  def route(json = %{:type => "max", :max => _}, state = %{ :hardware_id => hardware_id }) do
    HardwareStore.get(hardware_id)
    |> get_monitor_pid
    |> update_monitor_max(json, state)
  end

  def route(_json = %{:type => "connected"}, state = %{ :hardware_id => hardware_id}) do
    HardwareStore.connected(hardware_id)
    |> connection_status(state)
  end

  def route(_json = %{:type => "connected"}, state) do
    connection_status(false, state)
  end

  def route(_json = %{:type => "ping"}, state) do
    Response.reply("OK", 200, "Pong", @response_types.pong, state)
  end

  def route(_json, state) do
    Response.error("Not Found.", 404, "No hardware id.", @response_types.error, state)
  end

  # private

  # TODO: This below honestly needs cleaned up, problem is with needing to rely
  # on Monitor.State being alive or not and error handling if it is not.

  defp get_monitor_pid(_hardware_store = %{ :monitor_pid => monitor_pid }) do
    pid = DynamicSupervisor.which_children(Monitor.DynamicSupervisor)
    |> Enum.find(fn child -> elem(child, 1) == monitor_pid end)
    |> elem(1)

    case monitor_pid do
      ^pid ->
        { :ok, monitor_pid }
      _ ->
        {:error, :proccess_not_started}
    end
  end

  defp get_monitor_pid(_hardware_store = nil), do: {:error, :proccess_not_started}

  defp get_monitor({:ok, pid}, state) do
    # Reinstating max, in case Monitor.Server restarted.
    # Note: Monitor.update returns the same thing as Monitor.get
    # TODO: Hacky af, fix later...
    monitor = case state do
      %{ :max => max } ->
        Monitor.update(pid, %{ :max => max })
      _ ->
        Monitor.get(pid)
    end

    Response.reply("OK", 200, monitor, @response_types.monitor, state)
  end

  defp get_monitor({:error, :proccess_not_started}, state) do
    process_not_started(state)
  end

  defp update_monitor_max({:ok, pid}, json, state) do
    pid
    |> Monitor.update(json)
    |> IO.inspect

    # In case Monitor.state shutsdown, we are storing max
    # so that we can resinstate it later.
    # TODO: Hacky af, fix later...
    state = Map.merge(state, %{ :max => json.max })

    Response.reply("OK", 200, "Max distance updated successfully.", @response_types.max, state)
  end

  defp update_monitor_max({:error, :proccess_not_started}, _json, state) do
    process_not_started(state)
  end

  defp connection_status(_connected = true, state) do
    Response.reply("OK", 200, "Connected to hardware.", @response_types.connected, state)
  end

  defp connection_status(_connected = false, state) do
    Response.reply("OK", 200, "Disconnected from hardware.", @response_types.disconnected, state)
  end

  defp process_not_started(state) do
    Response.reply("OK", 200, "Process not started. Try again.", @response_types.process_not_started, state)
  end

end

# Example requests

# {
#   "type": "pair",
#   "hardware_id": "50e90b91c72a8a6531900e6c0b842ef3"
# }

# {
#   "type": "max",
#   "max": 80
# }

# {
#   "type": "monitor"
# }
