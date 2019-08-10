defmodule Websocket.HardwareStore do
  use Agent

  @me __MODULE__

  def start_link(_state) do
    Agent.start_link(fn -> [] end, name: @me)
  end

  @spec get(binary()) :: %{hardware_id: binary(), monitor_pid: pid()} | nil
  def get(hardware_id) do
    Agent.get(@me, & &1)
    |> Enum.find(& &1.hardware_id == hardware_id)
  end

  @spec connected(binary()) :: boolean()
  def connected(hardware_id) do
    Agent.get(@me, & &1)
    |> Enum.find(& &1.hardware_id == hardware_id) != nil
  end

  @doc """
    Accepts state `%{hardware_id: binary(), monitor_pid: pid()}`

    Returns `:ok`
  """
  @spec add(%{hardware_id: binary(), monitor_pid: pid()}) :: :ok
  def add(map = %{:hardware_id => _hardware_id, :monitor_pid => _monitor_pid}) do
    Agent.cast(@me, fn list -> list ++ [map] end)
  end

  def remove(hardware_id) do
    reject = fn map -> map.hardware_id == hardware_id end
    Agent.cast(@me, fn list -> Enum.reject(list, reject) end)
  end
end
