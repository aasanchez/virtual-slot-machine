defmodule OcppGateway.Kafka.KafkaAdapter do
  @doc """
  A behaviour for Kafka client operations, allowing for Mox in tests.
  """

  @callback produce(
              worker_name :: atom(),
              topic :: String.t(),
              partitioner :: atom() | integer(),
              messages :: list(%{key: String.t() | nil, value: String.t()})
            ) :: :ok | {:error, any()}

  # Add other Kafka functions that might be used if necessary
end
