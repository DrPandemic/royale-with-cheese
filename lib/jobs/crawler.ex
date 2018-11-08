defmodule Jobs.Crawler do
  use Toniq.Worker

  def perform(region: region, realm: realm) do
    IO.puts "Starting #{realm}"
    id = System.get_env("BLIZZARD_CLIENT_ID")
    secret = System.get_env("BLIZZARD_CLIENT_SECRET")
    %{"access_token" => token} = Wow.Crawler.get_access_token(id, secret)
    %{"files" => [%{
      "lastModified" => last_modified,
      "url" => url
    }]} = Wow.Crawler.get_url(token, region, realm)
    dump = Wow.Crawler.get_dump(url)

    IO.puts "Done #{realm}"
  end
end
