defmodule OcppGateway.Kafka.Producer do
  require Logger
  # alias OcppGateway.Kafka.KafkaAdapter # Ensure this is removed or commented if unused. It IS used via Application.get_env.

  @kafka_topic "ocpp.events.in"
  # Using a default worker name, this might need to be configured or passed if multiple producers are needed
  @kafka_worker_name :kafka_ex_worker

  defp kafka_adapter, do: Application.get_env(:ocpp_gateway, :kafka_adapter, KafkaEx)

  # Publishes a message to Kafka.
  # Expects a map like %{connection_id: "some_id", ocpp_payload: %{"messageId" => "msg_id", ...}}
  def publish(%{connection_id: connection_id, ocpp_payload: ocpp_payload} = kafka_message_content) do
    case Jason.encode(kafka_message_content) do
      {:ok, json_message} ->
        kafka_message_key = Map.get(ocpp_payload, "messageId") # Assumes messageId is a string or nil

        adapter = kafka_adapter()
        Logger.debug("Kafka.Producer: Using adapter #{inspect(adapter)} to publish.")

        case adapter.produce(@kafka_worker_name, @kafka_topic, :random_partitioner, [%{key: kafka_message_key, value: json_message}]) do
          :ok ->
            Logger.info("Kafka: successfully published message for connection_id '#{connection_id}' to topic '#{@kafka_topic}'. Key: #{inspect(kafka_message_key)}")
            :ok
          {:error, reason} ->
            Logger.error("Kafka: failed to publish message for connection_id '#{connection_id}' using adapter #{inspect(adapter)}. Reason: #{inspect(reason)}")
            {:error, reason}
        end

      {:error, json_error} ->
        Logger.error("Kafka: failed to encode message to JSON for connection_id '#{connection_id}'. Error: #{inspect(json_error)}")
        {:error, :json_encoding_failed}
    end
  end

  # Fallback clause for payloads with an unexpected structure.
  def publish(other_payload) do
    Logger.error("Kafka: received payload with unexpected structure for publishing: #{inspect(other_payload)}")
    {:error, :invalid_payload_structure}
  end
end
