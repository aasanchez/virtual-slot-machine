defmodule OcppGatewayWeb.OcppChannel do
  use Phoenix.Channel
  require Logger

  @impl true
  def join("ocpp:lobby", _payload, socket) do
    Logger.info("Channel: client joined ocpp:lobby")
    {:ok, socket}
  end

  # Default join for any other topic (optional, can be removed if only "ocpp:lobby" is allowed)
  def join(_topic, _payload, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  @impl true
  def handle_in(event, payload, socket) do
    connection_id = inspect(self()) # Using the channel's process ID as connection_id
    Logger.info("Channel: received event '#{event}' on connection_id '#{connection_id}'")

    case Jason.decode(payload) do
      {:ok, json_payload} ->
        Logger.info("Channel: parsed payload for connection_id '#{connection_id}': #{inspect(json_payload)}")
        kafka_message = %{connection_id: connection_id, ocpp_payload: json_payload}
        OcppGateway.Kafka.Producer.publish(kafka_message) # Call Kafka producer
      {:error, error} ->
        Logger.error("Channel: failed to parse JSON payload for connection_id '#{connection_id}'. Error: #{inspect(error)}")
    end

    {:noreply, socket}
  end
end
