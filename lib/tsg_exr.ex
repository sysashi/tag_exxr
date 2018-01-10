defmodule TsgExr do
  @moduledoc false

  defstruct [:amount, :currency_left, :modifier, :currency_right]

  def apply_rates(%__MODULE__{} = data, rates) do
    rates
    |> Map.take(data.currency_right)
    |> Enum.map(fn {currency, rate} -> "#{calc(rate, data.amount)} #{currency}" end)
  end


  def parse(data) do
    case exctract(data) do
      map when is_map(map) ->
        fields = map |> Enum.map(&normalize/1) |> keys_to_atoms()
        {:ok, struct(__MODULE__, fields)}
      nil ->
        {:error, :malformed_data, data}
    end
  end

  defp exctract(data) do
    Regex.named_captures(~r/
      (?<amount>(\d*\.)?\d+)\s*
      (?<currency_left>\w+\b)\s*
      (?<modifier>to|in)\s*
      (?<currency_right>(\w*\,)?\s?\w*)/xi,
    data)
  end

  defp normalize({"currency_" <> p = key, currency}), do: {key, normalize_currency(p, currency)}
  defp normalize({"amount" = key, amount}) do
    {amount, _} = Float.parse(amount)
    {key, amount}
  end
  defp normalize(kv), do: kv

  defp normalize_currency("left", currency), do: String.upcase(currency)
  defp normalize_currency("right", currency) do
    currency
    |> String.upcase
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.upcase/1)
  end

  defp keys_to_atoms(map) do
    for {k, v} <- map, do: {String.to_existing_atom(k), v}
  end

  defp calc(rate, amount), do: Float.floor(rate * amount, 2)
end
