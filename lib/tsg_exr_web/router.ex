defmodule TsgExrWeb.Router do
  use TsgExrWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/webhook", TsgExrWeb do
    pipe_through :api

    post "/", WebhookController, :process
  end
end
