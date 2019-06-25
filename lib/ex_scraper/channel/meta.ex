defmodule ExScraper.Channel.Meta do
  alias __MODULE__

  defstruct url: "",
            parse_info: nil,
            headers: [],
            data: ""

  @spec new(ExScraper.Channel.parse_info(), List.t(), binary()) :: ExScraper.Channel.Meta.t()
  def new(parse_info, headers, data) do
    %Meta{url: parse_info.origin, parse_info: parse_info, headers: headers, data: data}
  end
end
