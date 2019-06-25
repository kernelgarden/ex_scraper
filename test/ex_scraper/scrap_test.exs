defmodule ExScraper.ScrapTest do
  use ExUnit.Case, async: true

  alias ExScraper.Scrap

  test "Build Scrap" do
    #assert {:ok, scrap} = Scrap.build("https://www.naver.com")

    assert {:ok, scrap} = Scrap.build("https://sports.news.naver.com/epl/news/read.nhn?oid=139&aid=0002108258")

    IO.inspect(scrap)

  end
end
