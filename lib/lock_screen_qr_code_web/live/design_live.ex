defmodule LockScreenQRCodeWeb.DesignLive do
  use LockScreenQRCodeWeb, :live_view
  require Logger
  alias LockScreenQRCode.Requests
  alias LockScreenQRCode.Generator

  @templates [
    %{id: "pop_vibes", name: "Pop Vibes", gradient: "from-pink-400 to-purple-500"},
    %{id: "ocean_blue", name: "Ocean Blue", gradient: "from-teal-400 to-blue-500"},
    %{id: "sunny_side", name: "Sunny Side", gradient: "from-yellow-400 to-orange-500"},
    %{id: "monochrome", name: "Monochrome", gradient: "from-gray-800 to-gray-900"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:lock_screen_qr_code, :design_live, :mount], %{status: :start})

    # QR request is now always available due to the hook creating one if needed
    if socket.assigns[:qr_request] do
      Logger.info("DesignLive mounted with QR request: #{socket.assigns.qr_request.id}")
    else
      Logger.warning("QR request should have been created by hook but wasn't found")
    end

    templates = @templates

    # Default to the first template if none is selected
    template = socket.assigns[:qr_request].template || List.first(templates).id

    # Generate QR code for preview
    qr_preview = generate_qr_preview(socket.assigns[:qr_request].url)

    {:ok, assign(socket, templates: templates, selected_template: template, qr_preview: qr_preview)}
  end

  @impl true
  def handle_event("select_template", %{"template" => template_id}, socket) do
    Logger.info("Selected template: #{template_id}")

    # Update the QR request with the selected template
    case Requests.update_qr_request(socket.assigns.qr_request, %{template: template_id}) do
      {:ok, updated_qr_request} ->
        # Generate QR code preview with the new template
        qr_preview = generate_qr_preview(updated_qr_request.url)

        {:noreply,
         socket
         |> assign(:qr_request, updated_qr_request)
         |> assign(:selected_template, template_id)
         |> assign(:qr_preview, qr_preview)}

      {:error, _changeset} ->
        Logger.error("Failed to update template for QR request: #{socket.assigns.qr_request.id}")
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("back", _params, socket) do
    # Navigate back to create page - QR request will be loaded from session by hook
    {:noreply, push_navigate(socket, to: ~p"/create", replace: true)}
  end

  @impl true
  def handle_event("continue", _params, socket) do
    # Navigate to preview page
    {:noreply, push_navigate(socket, to: ~p"/preview")}
  end

  # Private functions

  # Generate a QR code preview as a base64 data URL
  defp generate_qr_preview(url) do
    Logger.info("Generating QR code preview for URL: #{url}")

    # Generate QR code using the updated Generator module
    result = Generator.generate(url, format: :png)

    # Handle the result, using nil for any error case
    case result do
      {:ok, qr_binary} when is_binary(qr_binary) ->
        # Log success
        byte_size = byte_size(qr_binary)
        Logger.info("QR code generated successfully: #{byte_size} bytes")

        # Add watermark for preview
        # The add_preview_watermark function always returns {:ok, binary} for now
        watermark_result = Generator.add_preview_watermark(qr_binary)

        case watermark_result do
          {:ok, watermarked_binary} ->
            # Convert to base64 data URL for display in img tag
            data_url = "data:image/png;base64," <> Base.encode64(watermarked_binary)
            Logger.info("QR code data URL generated (length: #{String.length(data_url)})")
            data_url

          # This case is added for future compatibility if the function is changed
          _other ->
            Logger.error("Unexpected watermark result: #{inspect(watermark_result)}")
            nil
        end

      _error_or_invalid_binary ->
        Logger.error("Failed to generate valid QR code binary")
        nil
    end
  rescue
    e ->
      Logger.error("Exception while generating QR code: #{inspect(e)}")
      nil
  end
end
