defmodule OcppGateway.Kafka.ProducerTest do
  use ExUnit.Case, async: true
  import Mox # Import Mox for mocking

  alias OcppGateway.Kafka.Producer

  setup do
    # Configure the Kafka adapter to use the mock for this test process
    Application.put_env(:ocpp_gateway, :kafka_adapter, KafkaExMock)
    # Clean up the application environment after the test
    on_exit(fn -> Application.delete_env(:ocpp_gateway, :kafka_adapter) end)
    :ok
  end

  describe "publish/1" do
    test "successfully publishes a correctly formatted message to Kafka" do
      connection_id = "conn_test_123"
      ocpp_payload = %{"messageId" => "msg_id_001", "action" => "BootNotification"}

      kafka_message_to_publish = %{
        connection_id: connection_id,
        ocpp_payload: ocpp_payload
      }

      expected_json_value = Jason.encode!(kafka_message_to_publish)
      expected_kafka_key = "msg_id_001"
      expected_topic = "ocpp.events.in"
      expected_worker_name = :kafka_ex_worker # As defined in Producer module

      # Set expectation on the mock
      # KafkaExMock.produce(worker_name, topic, partitioner, messages)
      expect(KafkaExMock, :produce, fn worker_name, topic, _partitioner, messages_payload_list ->
        assert worker_name == expected_worker_name
        assert topic == expected_topic
        assert length(messages_payload_list) == 1

        [message_payload] = messages_payload_list
        assert message_payload.key == expected_kafka_key
        assert message_payload.value == expected_json_value

        :ok # Return value for the mocked function
      end)

      # Call the function under test
      assert Producer.publish(kafka_message_to_publish) == :ok

      # Verify all expectations are met (optional, as expect/3 does this if the function is called)
      # verify!(KafkaExMock)
    end

    test "handles JSON encoding failure" do
      # Create a payload that cannot be JSON encoded (e.g., containing a PID)
      bad_ocpp_payload = %{"pid" => self()}
      kafka_message_with_bad_payload = %{
        connection_id: "conn_test_456",
        ocpp_payload: bad_ocpp_payload
      }

      # No expectation on KafkaExMock.produce as it shouldn't be called
      # We expect an error from the publish function itself due to Jason.encode failing

      log_output = ExUnit.CaptureLog.capture_log fn ->
         assert Producer.publish(kafka_message_with_bad_payload) == {:error, :json_encoding_failed}
      end

      assert log_output =~ "Kafka: failed to encode message to JSON"
    end

    test "handles Kafka publish failure" do
      connection_id = "conn_test_789"
      ocpp_payload = %{"messageId" => "msg_id_002", "action" => "StatusNotification"}

      kafka_message_to_publish = %{
        connection_id: connection_id,
        ocpp_payload: ocpp_payload
      }

      # Set expectation on the mock to return an error
      expect(KafkaExMock, :produce, fn _, _, _, _ ->
        {:error, :kafka_publish_failed} # Simulate Kafka error
      end)

      log_output = ExUnit.CaptureLog.capture_log fn ->
        assert Producer.publish(kafka_message_to_publish) == {:error, :kafka_publish_failed}
      end

      assert log_output =~ "Kafka: failed to publish message"
      assert log_output =~ ":kafka_publish_failed"
    end
  end
end
