defmodule LockScreenQRCodeWeb.CheckoutLive do
  use LockScreenQRCodeWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:lock_screen_qr_code, :checkout_live, :mount], %{status: :start})
    Logger.info("CheckoutLive mounted")
    {:ok, socket}
  end
end
