defmodule Wow.Crawler do
  alias Tesla.Multipart
  @access_token_url "https://us.battle.net/oauth/token"

  @spec get_access_token(String.t, String.t) :: String.t
  def get_access_token(id, secret) do
    client = Tesla.client(middlewares_basic_auth(id, secret))
    mp = Multipart.new |> Multipart.add_field("grant_type", "client_credentials")
    case Tesla.post(
      client,
      @access_token_url,
      mp
    ) do
      {:ok, %Tesla.Env{status: 200, body: %{"access_token" => token}}} ->
        token
    end
  end

  @spec get_url(String.t, String.t, String.t) :: %{lastModified: integer, url: String.t}
  def get_url(access_token, region, realm) do
    client = Tesla.client(middlewares())
    case Tesla.get(
      client,
      "https://#{region}.api.blizzard.com/wow/auction/data/#{realm}?locale=en_US&access_token=#{access_token}"
    ) do
      {:ok, %Tesla.Env{status: 200, body: %{"files" => [body]}}} ->
        string_key_map(body)
    end
  end

  @spec get_dump(String.t) :: %{auctions: list(Wow.AuctionEntry.raw_entry)}
  def get_dump(url) do
    client = Tesla.client(middlewares())
    case Tesla.get(
      client,
      url
    ) do
      {:ok, %Tesla.Env{status: 200, body: %{"auctions" => auctions}}} ->
        auctions
    end
  end

  @spec middlewares() :: list
  defp middlewares() do
    if Mix.env == :test do
      [
        Tesla.Middleware.DecodeJson,
      ]
    else
      [
        Tesla.Middleware.DecodeJson,
        Tesla.Middleware.Compression,
        {Tesla.Middleware.Headers, [{"Accept-Encoding", "gzip"}]}
      ]
    end
  end

  @spec middlewares_basic_auth(String.t, String.t) :: list
  defp middlewares_basic_auth(id, secret) do
    if Mix.env == :test do
    [
      {Tesla.Middleware.BasicAuth, %{username: id, password: secret}},
      Tesla.Middleware.DecodeJson,
    ]
    else
      [
        {Tesla.Middleware.BasicAuth, %{username: id, password: secret}},
        Tesla.Middleware.DecodeJson,
        Tesla.Middleware.Compression,
        {Tesla.Middleware.Headers, [{"Accept-Encoding", "gzip"}]}
      ]
    end
  end

  @spec string_key_map(map) :: map
  defp string_key_map(map) do
    Map.new(map, fn {k, v} -> {String.to_atom(k), v} end)
  end
end
