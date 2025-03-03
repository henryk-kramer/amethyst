defmodule Amethyst.Process.Tcp.Endpoint do
  @moduledoc since: "1.7.2-0.1.0"
  @moduledoc """

  """
alias Amethyst.Processes.Tcp.Channel
alias Amethyst.Processes.Tcp.ChannelSupervisor

  use GenServer

  require Logger

  @type t :: %__MODULE__{open?: boolean(), socket: :gen_tcp.socket()}
  defstruct [
    :open?,
    :socket,
    :port
  ]

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(args) do
    args = Keyword.drop(args, [:name])
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @spec new_acceptor() :: :ok
  def new_acceptor() do
    GenServer.cast(__MODULE__, :new_acceptor)
  end

  @impl true
  def init(args) do
    port = Keyword.get(args, :port, 25565)
    opts = Keyword.drop(args, [:port])

    case :gen_tcp.listen(port, opts) do
    	{:ok, socket} ->
        Logger.info("Opened port #{port}")
        state = %__MODULE__{open?: true, socket: socket, port: port}
        {:ok, state, {:continue, :init_acceptors}}

      {:error, reason} ->
        Logger.error("Could not open port #{port} for reason '#{reason}'")
        {:stop, {:shutdown, reason}}
    end
  end

  @impl true
  def handle_continue(:init_acceptors, state) do
    Enum.each(1..4, fn _ -> new_acceptor() end)
    {:noreply, state}
  end

  @impl true
  def terminate(reason, %__MODULE__{open?: open?, socket: socket, port: port}) do
    if open? do
      :gen_tcp.close(socket)
      Logger.info("Closed port #{port}")
    end

    reason
  end

  @impl true
  def handle_cast(:new_acceptor, state) do
    DynamicSupervisor.start_child(ChannelSupervisor, {Channel, endpoint: state})
    {:noreply, state}
  end
end
