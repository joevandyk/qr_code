defmodule LockScreenQRCodeWeb.DownloadLive do
  use LockScreenQRCodeWeb, :live_view
  require Logger
  alias LockScreenQRCode.Requests
  alias LockScreenQRCode.Compositor
  alias LockScreenQRCode.Storage

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:lock_screen_qr_code, :download_live, :mount], %{status: :start})

    if socket.assigns[:qr_request] do
      Logger.info("DownloadLive mounted with QR request: #{socket.assigns.qr_request.id}")

      # Check if the image has already been generated
      image_url = socket.assigns.qr_request.preview_image_url

      if is_nil(image_url) do
        Logger.debug("No image URL found, generating new image")
        # Generate the image if it doesn't exist
        socket = generate_image(socket)
        {:ok, socket}
      else
        Logger.debug("Using existing image URL: #{image_url}")
        {:ok, assign(socket, image_url: image_url, error: nil)}
      end
    else
      Logger.warning("QR request not found for DownloadLive")
      {:ok, assign(socket, error: "QR request not found")}
    end
  end

  @impl true
  def handle_event("regenerate", _params, socket) do
    Logger.debug("Regenerating QR code image")

    # First update the QR request to clear the existing image URL
    qr_request = socket.assigns.qr_request

    case Requests.update_qr_request(qr_request, %{preview_image_url: nil}) do
      {:ok, updated_qr_request} ->
        # Generate a new image with the updated QR request
        socket = socket
                |> assign(:qr_request, updated_qr_request)
                |> generate_image()

        {:noreply, socket}

      {:error, _changeset} ->
        Logger.error("Failed to update QR request to clear image URL")
        {:noreply, assign(socket, error: "Failed to regenerate image")}
    end
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

  # Helper function to generate the image
  defp generate_image(socket) do
    qr_request = socket.assigns.qr_request
    Logger.debug("Generating image for QR request: #{inspect(qr_request)}")

    # Generate a unique key for the image
    key = "#{qr_request.id}_#{:os.system_time(:millisecond)}"
    Logger.debug("Generated key: #{key}")

    # Extract text for overlay if available
    text = qr_request.name
    Logger.debug("Using text for overlay: #{inspect(text)}")

    # Generate the image with text overlay
    Logger.debug("Calling Compositor.compose with URL: #{qr_request.url}, template: #{qr_request.template}")
    case Compositor.compose(qr_request.url, qr_request.template, text: text) do
      {:ok, binary} ->
        Logger.debug("Compositor returned image binary, size: #{byte_size(binary)} bytes")

        # Store the image
        Logger.debug("Storing image with key: #{key}")
        case Storage.store(key, binary) do
          {:ok, url} ->
            Logger.debug("Image stored, URL: #{url}")

            # Update the QR request with the image URL
            Logger.debug("Updating QR request with URL: #{url}")
            case Requests.update_qr_request(qr_request, %{preview_image_url: url}) do
              {:ok, updated_qr_request} ->
                Logger.info("QR image generated and stored: #{url}")
                assign(socket, qr_request: updated_qr_request, image_url: url, error: nil)
              {:error, changeset} ->
                Logger.error("Failed to update QR request with image URL: #{inspect(changeset)}")
                assign(socket, error: "Failed to update QR request with image URL")
            end
          {:error, reason} ->
            Logger.error("Failed to store QR image: #{inspect(reason)}")
            assign(socket, error: "Failed to store QR image")
        end
      {:error, reason} ->
        Logger.error("Failed to generate QR image: #{inspect(reason)}")
        assign(socket, error: "Failed to generate QR image")
    end
  end
end
