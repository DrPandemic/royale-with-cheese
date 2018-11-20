defmodule WowWeb.Router do
  use WowWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WowWeb do
    pipe_through :browser

    get "/", HomeController, :index
    get "/items", ItemController, :show
    get "/items/find", ItemController, :find
  end

  # Other scopes may use custom stacks.
  # scope "/api", WowWeb do
  #   pipe_through :api
  # end
end
