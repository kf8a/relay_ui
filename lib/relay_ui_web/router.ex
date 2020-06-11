defmodule RelayUiWeb.Router do
  use RelayUiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
#    plug :put_root_layout, {RelayUiWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  if Mix.env() == :dev do
    forward "/sent-emails", Bamboo.SentEmailViewerPlug
  end

  scope "/", RelayUiWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/admin", PageController, :admin

    resources "/login-requests", LoginRequestController,
      only: [:create, :new, :show],
      param: "token"

    resources "/sessions", SessionController, only: [:delete], singleton: true
  end

  # Other scopes may use custom stacks.
  # scope "/api", RelayUiWeb do
  #   pipe_through :api
  # end
end
