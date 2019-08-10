defmodule Websocket.Helpers.Jsn do
  def to_json(json_string) do
    json_string
    |> Poison.decode!
    |> Enum.reduce(%{}, fn({ key, value }, acc) -> Map.put(acc, String.to_atom(key), value) end)
  end
end
