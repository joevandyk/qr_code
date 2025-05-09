defmodule LockScreenQRCodeWeb.PreviewLive do
  use LockScreenQRCodeWeb, :live_view
  require Logger
  alias LockScreenQRCode.Generator
  alias LockScreenQRCode.Templates

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:lock_screen_qr_code, :preview_live, :mount], %{status: :start})

    if socket.assigns[:qr_request] do
      Logger.info("PreviewLive mounted with QR request: #{socket.assigns.qr_request.id}")

      # Get the URL and template from the QR request
      url = socket.assigns.qr_request.url
      template_id = socket.assigns.qr_request.template

      # Generate a preview SVG for display in the browser
      case Generator.generate_svg(url, qr_color: "#ffffff", background_color: "transparent") do
        {:ok, svg_data} ->
          # Get template info for the selected template
          template_gradient = Templates.get_gradient(template_id)

          {:ok, assign(socket,
            svg_qr_code: svg_data,
            template_gradient: template_gradient,
            error: nil
          )}
        {:error, reason} ->
          Logger.error("Failed to generate QR code preview: #{inspect(reason)}")
          {:ok, assign(socket, error: "Failed to generate QR code preview")}
      end
    else
      Logger.warning("QR request not found for PreviewLive")
      {:ok, socket}
    end
  end

  @impl true
  def handle_event("back", _params, socket) do
    # Navigate back to the design page
    {:noreply, push_navigate(socket, to: ~p"/design", replace: true)}
  end

  @impl true
  def handle_event("continue", _params, socket) do
    # Navigate to the download page
    {:noreply, push_navigate(socket, to: ~p"/download")}
  end
end
