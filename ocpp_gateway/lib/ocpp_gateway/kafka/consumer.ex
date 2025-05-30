defmodule OcppGateway.Kafka.Consumer do
  require Logger

  # This function is expected to be called by KafkaEx for each batch of messages.
  # The `_arg` parameter's content/usage depends on KafkaEx's specific implementation
  # for callback modules (it might be initial config or runtime state).
  def handle_messages(messages, _arg \\ nil) do
    Enum.each(messages, fn %KafkaEx.Protocol.Fetch.Message{} = msg ->
      Logger.debug("Kafka.Consumer: Received Kafka message from topic '#{msg.topic}' partition #{msg.partition}")

      case Jason.decode(msg.value) do
        {:ok, %{"connection_id" => connection_id, "payload_to_send" => payload_to_send}} ->
          Logger.info("Kafka.Consumer: Parsed message for connection_id '#{connection_id}'. Payload to send: #{inspect(payload_to_send)}")

          # Placeholder for finding and sending to WebSocket client
          Logger.info("Kafka.Consumer: Attempting to find WebSocket client for connection_id '#{connection_id}' to send payload.")
          # Example: OcppGatewayWeb.Endpoint.broadcast("ocpp:" <> connection_id, "downstream_message", payload_to_send)
          # Actual implementation would require a mapping from connection_id to channel PID or a PubSub topic.

        {:ok, other_json_structure} ->
          Logger.warn("Kafka.Consumer: Received message with unexpected JSON structure: #{inspect(other_json_structure)}")

        {:error, error} ->
          Logger.error("Kafka.Consumer: Failed to parse JSON payload from Kafka. Error: #{inspect(error)}. Raw value: #{inspect(msg.value)}")
      end
    end)
    # Indicate successful processing of the batch.
    # The exact return value expected by KafkaEx for a callback module needs to be confirmed from its documentation.
    # Common patterns are :ok, {:ok, new_state}, or specific ack mechanisms.
    # Assuming :ok is a safe default for stateless processing of a batch.
    :ok
  end

  # Optional: Define init/1 and terminate/2 if KafkaEx calls them for callback modules.
  # These are not standard GenServer callbacks if not `use GenServer`.
  # def init(arg) do
  #   Logger.info("Kafka.Consumer (callback module) initialized with: #{inspect(arg)}")
  #   {:ok, arg} # Or some initial state
  # end

  # def terminate(reason, state) do
  #   Logger.info("Kafka.Consumer (callback module) terminating. Reason: #{inspect(reason)}, State: #{inspect(state)}")
  #   :ok
  # end
end
