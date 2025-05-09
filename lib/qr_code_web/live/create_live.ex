defmodule QrCodeWeb.CreateLive do
  use QrCodeWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:qr_code, :create_live, :mount], %{status: :start})
    Logger.info("CreateLive mounted")
    {:ok, socket}
  end
end
