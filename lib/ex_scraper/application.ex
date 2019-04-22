defmodule ExScraper.Application do
  use Application

  require Logger

  def start(_, _) do
    Supervisor.start_link(
      [],
      strategy: :one_for_one
    )
  end
end
