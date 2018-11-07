defmodule Wow.Crawler do
  alias Tesla.Multipart
  @access_token_url "https://us.battle.net/oauth/token"

  def get_access_token(id, secret, module \\ Tesla) do
    client = module.client(middlewares_basic_auth(id, secret))
    mp = Multipart.new |> Multipart.add_field("grant_type", "client_credentials")
    case module.post(
      client,
      @access_token_url,
      mp
    ) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        body
    end
  end

  def get_url(access_token, region, realm, module \\ Tesla) do
    client = module.client(middlewares())
    case module.get(
      client,
      "https://#{region}.api.blizzard.com/wow/auction/data/#{realm}?locale=en_US&access_token=#{access_token}"
    ) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        body
    end
  end

  def get_dump(url, module \\ Tesla) do
    client = module.client(middlewares())
    case module.get(
      client,
      url
    ) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        body
    end
  end

  def middlewares() do
    [
      Tesla.Middleware.DecodeJson,
      Tesla.Middleware.Compression,
      {Tesla.Middleware.Headers, [{"Accept-Encoding", "gzip"}]}
    ]
  end

  def middlewares_basic_auth(id, secret) do
    [
      {Tesla.Middleware.BasicAuth, %{username: id, password: secret}},
      Tesla.Middleware.DecodeJson,
      Tesla.Middleware.Compression,
      {Tesla.Middleware.Headers, [{"Accept-Encoding", "gzip"}]}
    ]
  end
end
