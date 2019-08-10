defmodule Websocket.Router.Hardware do

  alias Websocket.Response
  alias Websocket.HardwareStore

  @response_types %{
    :ready   => "ready",
    :created => "created",
    :updated => "updated",
    :error   => "error"
  }

  def route(_json = %{:type => "ready"}, state) do
    Response.reply("Ready", 200, "Connected to server.", @response_types.ready, state)
  end

  def route(_json = %{:type => "create_hardware_id"}, state = %{ :hardware_id => _hardware_id}) do
    Response.error("Unprocessable Entity", 422, "Hardware id already created.", @response_types.error, state)
  end

  def route(json = %{:type => "create_hardware_id"}, state) do
    { :ok, monitor_pid } = Monitor.start_link(%{ :max => 151, :min => 19, :distance => 151 })

    new_state = %{
      :hardware_id => json.hardware_id,
      :monitor_pid => monitor_pid
    }

    HardwareStore.add(new_state)

    state = Map.merge(state, new_state)

    Response.reply("Created", 201, "Hardware id created.", @response_types.created, state)
  end

  def route(json = %{:type => "update_distance"}, state) do
    state.monitor_pid
    |> Monitor.update(json)
    |> IO.inspect # Not needed, but useful for debugging

    Response.reply("OK", 200, "Distance updated successfully.", @response_types.updated, state)
  end

  def route(_json, state) do
    Response.error("Not Found.", 404, "No hardware id.", @response_types.error, state)
  end
end

# Example Requests

# {
#   "type": "create_hardware_id",
#   "hardware_id": "123"
# }

# {
#   "type": "update_distance",
#   "distance": 40
# }
