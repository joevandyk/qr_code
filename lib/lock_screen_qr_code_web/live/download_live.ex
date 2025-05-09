defmodule LockScreenQRCodeWeb.DownloadLive do
  use LockScreenQRCodeWeb, :live_view
  require Logger
  alias LockScreenQRCode.Requests
  alias LockScreenQRCode.Compositor

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:lock_screen_qr_code, :download_live, :mount], %{status: :start})

    if socket.assigns[:qr_request] do
      Logger.info("DownloadLive mounted with QR request: #{socket.assigns.qr_request.id}")
      {:ok, assign(socket, error: nil)}
    else
      Logger.warning("QR request not found for DownloadLive")
      {:ok, assign(socket, error: "QR request not found")}
    end
  end

  @impl true
  def handle_event("regenerate", _params, socket) do
    # In the new approach, we don't need to regenerate - images are always generated on-demand
    # Just refresh the page to trigger a new image generation
    {:noreply, socket}
  end

  @impl true
  def handle_event("create_another", _params, socket) do
    # Navigate back to the create page
    {:noreply, push_navigate(socket, to: ~p"/create", replace: true)}
  end

  @impl true
  def handle_event("back", _params, socket) do
    # Navigate back to the preview page
    {:noreply, push_navigate(socket, to: ~p"/preview", replace: true)}
  end

  # Get image URL using the QR request token (more secure than using ID)
  # Adding cache-busting parameter based on content and simple timestamp
  def get_image_url(qr_request) do
    # Create a simple cache-busting parameter using a hash of the URL and template
    content_hash = :crypto.hash(:md5, "#{qr_request.url}#{qr_request.template}")
                   |> Base.encode16(case: :lower)

    # Use current timestamp to ensure freshness on updates
    timestamp = System.system_time(:second)

    "/qr-images/#{qr_request.token}?v=#{timestamp}_#{content_hash}"
  end
end
