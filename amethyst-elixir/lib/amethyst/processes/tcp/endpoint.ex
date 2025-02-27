defmodule Amethyst.Process.Tcp.Endpoint do
  @moduledoc since: "1.7.2-0.1.0"
  @moduledoc """

  """

  use GenServer

  require Logger

  defstruct [
    :open?,
    :socket
  ]

  @type t :: %Amethyst.Process.Tcp.Endpoint{open?: boolean(), socket: :gen_tcp.socket()}

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @doc false
  @impl true
  @spec init(any()) :: {:ok, %Amethyst.Process.Tcp.Endpoint{}}
  def init(_args) do
    {:ok, %__MODULE__{}}
  end
end
