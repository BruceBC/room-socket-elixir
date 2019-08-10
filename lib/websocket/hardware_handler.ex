defmodule Websocket.HardwareHandler do

  alias Websocket.Helpers.Jsn
  alias Websocket.Router
  alias Websocket.HardwareStore

  require Logger

  @behaviour :cowboy_websocket

  def init(req, _state) do
    # Help reduce latency when user disconnects
    opts = %{:idle_timeout => 10_000}
    {:cowboy_websocket, req, %{ :client => req.pid }, opts}
  end

  def websocket_init(state) do
    Logger.debug("Connected")
    Router.Hardware.route(%{:type => "ready"}, state)
  end

  def websocket_handle({:text, json}, state) do
    Jsn.to_json(json)
    |> IO.inspect
    |> Router.Hardware.route(state)
  end

  def websocket_info(message, state) do
    {:reply, {:text, message}, state}
  end

  def terminate(_reason, _partial_req, %{ :hardware_id => hardware_id, :monitor_pid => monitor_pid }) do
    Logger.debug("terminated!")
    Monitor.stop(monitor_pid)
    HardwareStore.remove(hardware_id)
  end

  def terminate(_reason, _partial_req, _state) do
    Logger.debug("terminated!")
    :ok
  end
end
