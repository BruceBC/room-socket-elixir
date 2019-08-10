defmodule Websocket.Helpers.System do
  def ip(:find) do
    :inet.getifaddrs()
    |> elem(1)
    |> ip
  end

  def ip([head | tail]) do
    list = head |> elem(1)

    (Enum.find(list, fn {key, value} -> evaluate(key, value) end) || tail)
    |> ip()
  end

  def ip({:addr, result}) when is_tuple(result) do
    result
    |> Tuple.to_list()
    |> Enum.join(".")
  end

  def ip([]) do
    :no_results
  end

  defp evaluate(:addr, value) when is_tuple(value) do
    if size(value) == 4 && value != {127, 0, 0, 1} do
      true
    else
      false
    end
  end

  defp evaluate(_key, _value), do: false

  defp size(value) do
    Enum.count(Tuple.to_list(value))
  end
end
