defmodule ExScraper.Result do
  @type t :: :ok | error()
  @type t(type) :: {:ok, type} | error()

  @type error :: {:error, reason}

  @type reason :: binary()
end
