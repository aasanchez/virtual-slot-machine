defmodule OcppGatewayWeb.UserSocket do
  use Phoenix.Socket

  # Define channels your socket supports.
  channel "ocpp:lobby", OcppGatewayWeb.OcppChannel

  # Transports
  #
  # Configure transport specific options, for example:
  #
  #   transport :websocket, Phoenix.Transports.WebSocket,
  #     timeout: 45_000
  #
  # See The Phoenix.Socket documentation for further details.
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be available for all channels.
  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user
  # Should return `nil` if the socket is not identified yet.
  @impl true
  def id(_socket), do: nil
end
