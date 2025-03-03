defmodule Amethyst.Application do
  alias Amethyst.Processes.Tcp.ChannelSupervisor
  use Application

  @impl true
  def start(_type, _args) do
    if Mix.env() != :prod do
      :observer.start()
    end

    children = [
      ChannelSupervisor,
      {Amethyst.Process.Tcp.Endpoint, port: 25000},
    ]

    opts = [strategy: :one_for_one, name: Amethyst.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
