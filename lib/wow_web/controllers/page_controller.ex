defmodule WowWeb.PageController do
  use WowWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
