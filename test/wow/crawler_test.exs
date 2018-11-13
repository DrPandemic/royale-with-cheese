defmodule Wow.CrawlerTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock

  setup do
    ExVCR.Config.filter_request_headers("authorization")
    ExVCR.Config.response_headers_blacklist(["x-trace-traceid", "x-trace-spanid", "x-trace-parentspanid"])
    :ok
  end

  test "#get_access_token returns a token" do
    use_cassette "get_access_token200" do
      id = System.get_env("BLIZZARD_CLIENT_ID")
      secret = System.get_env("BLIZZARD_CLIENT_SECRET")
      token = Wow.Crawler.get_access_token(id, secret)
      assert token =~ ~r/token/
    end
  end

  test "#get_access_token raises on bad credentials" do
    use_cassette "get_access_token401" do
      assert_raise CaseClauseError, fn ->
        Wow.Crawler.get_access_token("foo", "bar")
      end
    end
  end

  test "#get_url returns an url" do
    use_cassette "get_url200" do
      id = System.get_env("BLIZZARD_CLIENT_ID")
      secret = System.get_env("BLIZZARD_CLIENT_SECRET")
      token = Wow.Crawler.get_access_token(id, secret)
      %{url: url} = Wow.Crawler.get_url(token, "us", "medivh")
      assert url
    end
  end

  test "#get_url raises on bad realm" do
    use_cassette "get_url_bad_realm" do
      id = System.get_env("BLIZZARD_CLIENT_ID")
      secret = System.get_env("BLIZZARD_CLIENT_SECRET")
      token = Wow.Crawler.get_access_token(id, secret)
      assert_raise CaseClauseError, fn ->
        Wow.Crawler.get_url(token, "us", "foooo")
      end
    end
  end

  test "#get_dump returns dump" do
    use_cassette "dump200" do
      id = System.get_env("BLIZZARD_CLIENT_ID")
      secret = System.get_env("BLIZZARD_CLIENT_SECRET")
      token = Wow.Crawler.get_access_token(id, secret)
      %{url: url} = Wow.Crawler.get_url(token, "us", "medivh")
      dump = Wow.Crawler.get_dump(url)
      assert dump |> Enum.count == 2
    end
  end
end
