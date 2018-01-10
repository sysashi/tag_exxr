defmodule TsgExr.Lab do
  @moduledoc false

  use GenServer
  alias TsgExr.Request.Hackney

  ## API

  def reply(params, data) do
    GenServer.cast(__MODULE__, {:process, {params, data}})
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, []}
  end

  def handle_cast({:process, {params, data}}, queue) do
    send(self(), :notify)
    {:noreply, Enum.reduce(data, queue, &[{params, &1} | &2])}
  end

  def handle_info(:notify, queue) do
    notify(queue)
  end

  defp notify([]), do: {:noreply, []}
  defp notify([{params, entry} | rest]) do
    # have to log the response and retry in case of error
    Hackney.request(:post, params["response_url"], construct_payload(params, entry), headers())
    notify(rest)
  end

  defp construct_payload(%{"token" => token}, entry),
    do: Poison.encode!(%{token: token, body: entry})
  defp headers,
    do: [{"accept", "application/json"}, {"content-type", "application/json"}]
end
