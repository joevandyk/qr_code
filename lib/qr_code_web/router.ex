defmodule QrCodeWeb.Router do
  use QrCodeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {QrCodeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", QrCodeWeb do
    pipe_through :browser

    live "/", HomeLive
  end

  # Mockup routes for visual flow demonstration
  scope "/mockup", QrCodeWeb do
    pipe_through :browser

    get "/home", MockupController, :home
    get "/create", MockupController, :create
    get "/design", MockupController, :design
    get "/preview", MockupController, :preview
    get "/checkout", MockupController, :checkout
    get "/download", MockupController, :download
    get "/about", MockupController, :about
  end

  # Other scopes may use custom stacks.
  # scope "/api", QrCodeWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:qr_code, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: QrCodeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
