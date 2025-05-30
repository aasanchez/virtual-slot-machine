defmodule OcppGatewayWeb.OcppChannelTest do
  use OcppGatewayWeb.ChannelCase # Use ChannelCase for channel testing helpers
  alias OcppGatewayWeb.UserSocket
  require Logger
  import ExUnit.CaptureLog # To capture log messages

  # Test joining the channel
  test "join ocpp:lobby successfully" do
    {:ok, _, socket} =
      socket(UserSocket, "user_socket:123", %{}) # Connect to the UserSocket
      |> subscribe_and_join(OcppGatewayWeb.OcppChannel, "ocpp:lobby") # Join the OcppChannel

    assert socket.assigns[:id] == nil # Example assertion, UserSocket.id/1 returns nil
    assert socket.topic == "ocpp:lobby"
  end

  # Test handle_in with valid JSON
  test "handle_in receives and parses valid JSON" do
    {:ok, _, socket} =
      socket(UserSocket, "user_socket:valid_json", %{})
      |> subscribe_and_join(OcppGatewayWeb.OcppChannel, "ocpp:lobby")

    payload = %{"messageId" => "123", "action" => "BootNotification", "payload" => %{"reason" => "PowerUp"}}
    valid_json_string = Jason.encode!(payload)

    log_output =
      capture_log(fn ->
        # Push the message to the channel
        push(socket, "some_event", valid_json_string)
        # OcppChannel.handle_in logs the parsed payload. We are testing this logging.
      end)

    assert log_output =~ "Channel: parsed payload for connection_id"
    assert log_output =~ inspect(payload) # Check if the logged output contains the inspected original payload
    # The event name "some_event" is what we push, OcppChannel handle_in logs it.
    assert log_output =~ "Channel: received event 'some_event'"
  end

  # Test handle_in with invalid JSON
  test "handle_in handles invalid JSON gracefully" do
    {:ok, _, socket} =
      socket(UserSocket, "user_socket:invalid_json", %{})
      |> subscribe_and_join(OcppGatewayWeb.OcppChannel, "ocpp:lobby")

    invalid_json_string = "{\"messageId\": \"456\", \"action\": \"Heartbeat\"" # Incomplete JSON

    log_output =
      capture_log(fn ->
        push(socket, "another_event", invalid_json_string)
        # OcppChannel.handle_in logs an error for invalid JSON.
      end)

    assert log_output =~ "Channel: failed to parse JSON payload"
    assert log_output =~ "Channel: received event 'another_event'"
  end
end
