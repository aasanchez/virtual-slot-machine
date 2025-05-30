# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ocpp_gateway,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :ocpp_gateway, OcppGatewayWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    layout: false
  ],
  pubsub_server: OcppGateway.PubSub

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# Configure KafkaEx
config :kafka_ex,
  brokers: ['127.0.0.1'], # Simple list of charlist IPs/hosts
  consumer_group: "ocpp_gateway_group",
  # Optional: default topic for producers if not specified in produce call
  # default_topic: "ocpp.events.in",
  # Optional: default partitioner if not specified
  # default_partitioner: :random_partitioner,
  # Enable auto topic creation if your Kafka broker allows it (for development)
  allow_topic_auto_creation: true,
  consumers: [
    [
      module: OcppGateway.Kafka.Consumer,
      topics: ["ocpp.events.out"],
      consumer_group: "ocpp_gateway_group" # This should match the group name
    ]
  ]
