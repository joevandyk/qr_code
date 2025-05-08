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

    get "/step1", MockupController, :step1
    get "/step2", MockupController, :step2
    get "/step3", MockupController, :step3
    get "/step4", MockupController, :step4
    get "/step5", MockupController, :step5
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
