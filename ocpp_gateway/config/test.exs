import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ocpp_gateway, OcppGatewayWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "7OtqAoa/Q57FLtdBnao/cL18t533TJxZaFXIgeW62fChRuzDNQvms8nZBvUR4B+x",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Configure KafkaEx for test environment to be minimal and non-functional
config :kafka_ex,
  brokers: [], # Empty list of brokers
  consumers: [], # Disable consumers, also prevents consumer group setup attempts based on this
  client_id: "ocpp_gateway_test" # Optional, but can be good practice
