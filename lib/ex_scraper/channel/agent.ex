defmodule ExScraper.Channel.Agent do
  use Agent

  alias ExScraper.Channel

  @type channel_list :: [Channel.parse_info()]

  def start_link(_args) do
    Agent.start_link(fn -> [] end)
  end
end
