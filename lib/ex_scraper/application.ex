defmodule ExScraper.Application do
  use Application

  require Logger

  alias ExScraper.Connection.Registry
  alias ExScraper.Connection.Supervisor, as: ConnSupervisor

  def start(_, _) do
    Supervisor.start_link(
      [
        Registry,
        ConnSupervisor
      ],
      strategy: :one_for_one
    )
  end
end
