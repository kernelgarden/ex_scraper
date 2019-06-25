defmodule ExScraper.Channel.Table do
  alias :mnesia, as: Mnesia
  alias ExScraper.Channel

  @type scrap_info :: %{parse_info: Channel.parse_info(), result: %{}}

  def init() do
    Mnesia.create_schema([node()])
    Mnesia.start()
    validate_tables()
  end

  def write(%{__struct__: Channel, meta: meta, keywords: keywords}) do
    fn ->
      Mnesia.write({:channel})
    end
    |> do_write()
  end

  defp validate_tables() do
    # create channel table
    Mnesia.create_table(:channel, attributes: [:host, :meta, :keywords])

    # crate scrap table
    case Mnesia.create_table(:scrap, attributes: [:id, :channel_host, :scrap_info]) do
      {:atomic, :ok} ->
        # create index
        Mnesia.add_table_index(:scrap, :channel_id)

      {:aborted, _reason} ->
        # alreay exists
        :noop
    end
  end

  defp do_write(update_fun) do
    Mnesia.transaction(update_fun)
  end
end
