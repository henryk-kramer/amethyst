defmodule Amethyst.Processes.Tcp.Channel do
  alias Amethyst.Process.Tcp.Endpoint
  require Logger
  use GenServer, restart: :transient

  defstruct [
    :socket,
    :client
  ]

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(args) do
    args = Keyword.drop(args, [:name])
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init(args) do
    endpoint = Keyword.fetch!(args, :endpoint)

    {:ok, %__MODULE__{}, {:continue, {:accept, endpoint: endpoint}}}
  end

  @impl true
  def handle_continue({:accept, endpoint: endpoint}, state) do
    case :gen_tcp.accept(endpoint.socket) do
      {:ok, channel_socket} ->
        client = client_connection_string(channel_socket)
        Logger.info("Opened connection for client '#{client}'")

        Endpoint.new_acceptor()

        state = %__MODULE__{state | socket: channel_socket, client: client}
        {:noreply, state}

      {:error, reason} ->
        Logger.error("Could not open connection for reason '#{reason}'")
        {:noreply, state, {:continue, :accept}}
    end
  end

  @impl true
  def handle_info({:tcp_closed, _port}, %__MODULE__{client: client}) do
    Logger.info("Closed conenction for client '#{client}'")
    {:stop, :shutdown, nil}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.debug(inspect(msg))
    {:noreply, state}
  end

  defp client_connection_string(channel_socket) do
    case :inet.peername(channel_socket) do
      {:ok, {host, port}} ->
        host =
          host
          |> :inet.ntoa()
          |> List.to_string()

        "#{host}:#{port}"

      _ ->
        "unknown"
    end
  end
end
