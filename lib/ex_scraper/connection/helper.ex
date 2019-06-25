defmodule ExScraper.Connection.Helper do
  alias ExScraper.Connection.Registry, as: ConnRegistry

  def via_tuple(host) do
    ConnRegistry.via_tuple(host)
  end
end
