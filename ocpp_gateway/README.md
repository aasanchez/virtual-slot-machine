# OCPP Gateway

## Description

This application serves as an OCPP (Open Charge Point Protocol) 1.6J gateway. It acts as a bridge, handling WebSocket connections from OCPP clients (charging stations) and relaying their messages to Kafka topics. It also listens for messages from Kafka to potentially send responses or commands back to the connected clients.

## Prerequisites

*   Elixir ~> 1.14
*   Erlang/OTP ~> 25.0
*   Docker and Docker Compose (for running Kafka)

## Setup Instructions

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    cd ocpp_gateway
    ```

2.  **Install dependencies:**
    ```bash
    mix deps.get
    ```

3.  **Configure Kafka Brokers:**
    The Kafka broker addresses are configured in `config/config.exs`. By default, it's set to connect to Kafka running on `localhost:9092`.
    ```elixir
    # config/config.exs
    config :kafka_ex,
      brokers: [{'127.0.0.1', 9092}], # Or your Kafka broker addresses
      # ... other KafkaEx configurations
    ```
    Adjust the `brokers` list if your Kafka instance is running elsewhere. The current configuration `[{'127.0.0.1', 9092}]` was chosen after troubleshooting `kafka_ex`'s broker parsing in the test environment. Other formats like `['localhost:9092']` or `[{'localhost', 9092}]` might also work depending on the `kafka_ex` version and specific environment.

## Running Kafka with Docker

A simple single-node Kafka setup can be run using Docker Compose.

1.  **Create `docker-compose.yml`:**
    Create a `docker-compose.yml` file in the project root (or elsewhere) with the following content:

    ```yaml
    version: '3.8'
    services:
      kafka:
        image: bitnami/kafka:latest
        ports:
          - "9092:9092" # Exposes Kafka for the application
          - "9093:9093" # For inter-broker communication if needed, and client internal access
        environment:
          # KRaft settings
          - KAFKA_CFG_NODE_ID=0
          - KAFKA_CFG_PROCESS_ROLES=controller,broker
          - KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@kafka:9093
          # Listeners
          - KAFKA_CFG_LISTENERS=PLAINTEXT_HOST://:9092,CONTROLLER://:9093
          - KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT_HOST://localhost:9092
          - KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
          # Topic auto-creation
          - KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE=true
          # Other Bitnami Kafka specific settings (optional)
          - ALLOW_PLAINTEXT_LISTENER=yes
        volumes:
          - kafka_data:/bitnami/kafka
    volumes:
      kafka_data:
        driver: local
    ```

2.  **Start Kafka:**
    Navigate to the directory where you saved the `docker-compose.yml` file and run:
    ```bash
    docker-compose up -d
    ```
    This will start Kafka in detached mode.

3.  **Kafka Topics:**
    The application uses the following Kafka topics:
    *   `ocpp.events.in`: For messages received from OCPP clients and published by the gateway.
    *   `ocpp.events.out`: For messages consumed by the gateway, intended to be sent back to OCPP clients.
    With `KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE=true` in the Docker Compose setup, these topics should be created automatically when first used.

## Running the Application

To start the Phoenix server:

```bash
mix phx.server
```

Or, to run inside an IEx (Interactive Elixir) session:

```bash
iex -S mix phx.server
```

The application will start, and the WebSocket endpoint will be available at:
`ws://localhost:4000/socket`

## Testing

To run the test suite:

```bash
mix test
```
*Note: The test environment has shown some instability with `kafka_ex` application startup in certain conditions (specifically related to broker address parsing). Strategies have been implemented to mitigate this for unit tests (e.g., conditional supervision of `KafkaEx` in the test environment and providing a minimal `kafka_ex` configuration in `config/test.exs`). The tests for the core channel and producer logic use mocking and are designed to run independently of a live Kafka connection.*

## Connecting a WebSocket Client

1.  A WebSocket client (e.g., an OCPP 1.6J charging station simulator) should connect to:
    `ws://localhost:4000/socket`

2.  Once connected, the client needs to join the `"ocpp:lobby"` channel. The specific mechanism for joining a channel depends on the WebSocket client library used (e.g., sending a join message for the topic "ocpp:lobby").

3.  After joining the channel, the client can send OCPP messages. The gateway expects the payload of these messages to be a JSON string, sent for a specific event name (e.g., "ocpp_message" or any other event the client chooses to push). The `OcppChannel`'s `handle_in/3` function will attempt to parse this JSON string.

    Example structure of the **stringified JSON payload** expected by the channel's `handle_in` for an event like "new_msg" or "ocpp_event":

    ```json
    {
      "messageId": "unique-message-id-123",
      "action": "BootNotification",
      "payload": {
        "chargePointVendor": "ElixirHW",
        "chargePointModel": "EH-GatewayTester"
      }
    }
    ```

## Kafka Interaction

*   **Incoming Messages (Client to Kafka):** When an OCPP client sends a message to the WebSocket server on the `"ocpp:lobby"` channel (e.g., using event "new_msg"), the `OcppChannel` parses the JSON payload. This parsed payload, along with a `connection_id` (derived from the channel's process ID), is then formed into a map `%{connection_id: connection_id, ocpp_payload: parsed_json_payload}` and published to the `ocpp.events.in` Kafka topic by the `OcppGateway.Kafka.Producer`. The `messageId` from the OCPP message is used as the Kafka message key.

*   **Outgoing Messages (Kafka to Client - Conceptual):** The `OcppGateway.Kafka.Consumer` is configured to listen to the `ocpp.events.out` Kafka topic (using consumer group "ocpp_gateway_group"). When a message is consumed:
    *   It's parsed as JSON, expecting a structure like: `{"connection_id": "target_connection_id", "payload_to_send": {...}}`.
    *   The consumer logs the `connection_id` and `payload_to_send`.
    *   The current implementation includes a log statement indicating the conceptual step of finding the WebSocket client process associated with the `connection_id` to send the `payload_to_send`. The actual delivery mechanism back to a specific client (e.g., via `OcppGatewayWeb.Endpoint.broadcast`) is not yet fully implemented in the consumer logic.
```
