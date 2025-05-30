ExUnit.start()

# Define mocks for testing
Mox.defmock(KafkaExMock, for: OcppGateway.Kafka.KafkaAdapter)
