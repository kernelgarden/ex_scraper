defmodule ExScraper.Connection.Supervisor do
  use DynamicSupervisor

  require Logger

  def start_link(args \\ []) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def start_child(host) do
    DynamicSupervisor.start_child(__MODULE__, {ExScraper.Connection, host})
  end

  @impl true
  def init(_args) do
    Process.flag(:trap_exit, true)

    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def handle_info({:EXIT, from, reason}, state) do
    Logger.error(fn ->
      "Connection Process #{inspect(from)} is down. reason: #{inspect(reason)}"
    end)

    {:noreply, state}
  end
end
