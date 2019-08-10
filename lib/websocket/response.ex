defmodule Websocket.Response do

  def reply(status, status_code, data = %{}, type, state) do
    response = %{
      :status => status,
      :status_code => status_code,
      :data => data,
      :type => type
    }

    {:reply, {:text, Poison.encode!(response)}, state}
  end

  def reply(status, status_code, message, type, state) do
    response = %{
      :status => status,
      :status_code => status_code,
      :message => message,
      :type => type
    }

    {:reply, {:text, Poison.encode!(response)}, state}
  end

  def error(status, status_code, message, type, state) do
    reply(status, status_code, message, type, state)
  end

end
