defmodule TsgExr.ExchangeRates.Fixer do
  @moduledoc false

  alias TsgExr.Request.Hackney

  # cache result for 24h (expires on 4pm CET every wokring day)
  @ets :fixer_cache

  @api_host "api.fixer.io"
  @api_scheme "https"

  # supported params are: base, symbols
  def latest(params \\ %{}) do
    request(build_url("/latest", params))
  end

  # fixer supports dates >= 1999-01-04 (yyyy-mm-dd)
  def by_date(_date) do
    # format date
    # make request
    raise RuntimeError, "Not implemented!"
  end

  defp build_url(path, params \\ %{}) do
    %URI{
      scheme: @api_scheme,
      host: @api_host,
      path: path,
      query: URI.encode_query(params)
    }
    |> to_string()
    |> String.trim_trailing("?")
  end

  defp request(url) do
    case Hackney.request(:get, url, "", [{"accept", "application/json"}]) do
      {:ok, %{body: body, status_code: code}} when code in 200..299 ->
        {:ok, Poison.decode!(body)}
      {:ok, resp} ->
        {:resp_error, resp}
      {:error, reason} ->
        {:adapter_error, reason}
    end
  end
end
