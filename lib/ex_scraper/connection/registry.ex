defmodule ExScraper.Connection.Registry do
  def start_link() do
    Registry.start_link(keys: :unique, name: __MODULE__, partitions: System.schedulers_online())
  end

  def via_tuple(host) do
    {:via, Registry, {__MODULE__, host}}
  end

  def child_spec(_) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end
end
