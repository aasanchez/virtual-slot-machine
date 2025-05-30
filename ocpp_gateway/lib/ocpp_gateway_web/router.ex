defmodule OcppGatewayWeb.Router do
  use OcppGatewayWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", OcppGatewayWeb do
    pipe_through :api
  end
end
