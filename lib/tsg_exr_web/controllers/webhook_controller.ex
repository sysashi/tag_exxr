defmodule TsgExrWeb.WebhookController do
  use TsgExrWeb, :controller
  require Logger
  alias TsgExr.ExchangeRates.Fixer

  def process(conn, params) do
    with \
      {body, params} <- Map.pop(params, "body"),
      {:ok, data} <- TsgExr.parse(body),
      {:ok, %{"rates" => rates}} <- Fixer.latest(%{base: data.currency_left}) do
         TsgExr.Lab.reply(params, TsgExr.apply_rates(data, rates))
         send_resp(conn, 202, "")
    else
      reason ->
        Logger.warn "Unable to apply rates, #{inspect reason}"
        send_resp(conn, 500, "")
    end
  end
end
