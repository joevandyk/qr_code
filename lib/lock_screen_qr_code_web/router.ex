defmodule LockScreenQRCodeWeb.Router do
  use LockScreenQRCodeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LockScreenQRCodeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LockScreenQRCodeWeb do
    pipe_through :browser

    live "/", HomeLive

    # Regular controller action to initialize the QR request session
    get "/start", QrRequestController, :start

    # Route to serve QR code images directly
    get "/qr-images/:id", QRImageController, :show

    live_session :lock_screen_qr_code_flow,
      on_mount: {LockScreenQRCodeWeb.QrSessionHook, :ensure_qr_data} do
      live "/create", CreateLive
      live "/design", DesignLive
      live "/preview", PreviewLive
      live "/checkout", CheckoutLive
      live "/download", DownloadLive
    end

    live "/about", AboutLive
  end

  # Mockup routes for visual flow demonstration
  scope "/mockup", LockScreenQRCodeWeb do
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
  # scope "/api", LockScreenQRCodeWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:lock_screen_qr_code, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LockScreenQRCodeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
