defmodule OcppGateway.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        OcppGatewayWeb.Telemetry,
        # Conditionally start KafkaEx only if not in the test environment
        if(Mix.env() != :test, do: KafkaEx, else: []),
        {DNSCluster, query: Application.get_env(:ocpp_gateway, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: OcppGateway.PubSub},
        # Start a worker by calling: OcppGateway.Worker.start_link(arg)
        # {OcppGateway.Worker, arg},
        # Start to serve requests, typically the last entry
        OcppGatewayWeb.Endpoint
      ]
      |> List.flatten() # Ensure KafkaEx is properly added or removed without leaving nil
      |> Enum.reject(&is_nil(&1)) # In case if/else produced nil, though List.flatten handles empty list from else.

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OcppGateway.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OcppGatewayWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
