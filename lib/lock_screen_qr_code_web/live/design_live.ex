defmodule LockScreenQRCodeWeb.DesignLive do
  use LockScreenQRCodeWeb, :live_view
  require Logger
  alias LockScreenQRCode.Requests
  alias LockScreenQRCode.Generator
  import LockScreenQRCodeWeb.Components.PhonePreview

  @templates [
    %{id: "pop_vibes", name: "Pop Vibes", gradient: "from-pink-400 to-purple-500"},
    %{id: "ocean_blue", name: "Ocean Blue", gradient: "from-teal-400 to-blue-500"},
    %{id: "sunny_side", name: "Sunny Side", gradient: "from-yellow-400 to-orange-500"},
    %{id: "monochrome", name: "Monochrome", gradient: "from-gray-800 to-gray-900"},
    %{id: "clean_white", name: "Clean White", gradient: "from-gray-50 to-white"},
    %{id: "neon_glow", name: "Neon Glow", gradient: "from-green-400 via-blue-500 to-purple-600"},
    %{id: "sunset_dream", name: "Sunset Dream", gradient: "from-red-400 via-pink-500 to-purple-500"},
    %{id: "forest_mist", name: "Forest Mist", gradient: "from-emerald-400 to-teal-600"}
  ]

  # Define which templates use light theme (all others are dark)
  @light_templates ["clean_white"]

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
    theme = if template in @light_templates, do: "light", else: "dark"

    # Set qr_preview to nil since we'll use the component directly
    {:ok, assign(socket,
      templates: templates,
      selected_template: template,
      qr_preview: nil,
      theme: theme
    )}
  end

  @impl true
  def handle_event("select_template", %{"template" => template_id}, socket) do
    Logger.info("Selected template: #{template_id}")

    # Update the QR request with the selected template
    case Requests.update_qr_request(socket.assigns.qr_request, %{template: template_id}) do
      {:ok, updated_qr_request} ->
        theme = if template_id in @light_templates, do: "light", else: "dark"

        {:noreply,
         socket
         |> assign(:qr_request, updated_qr_request)
         |> assign(:selected_template, template_id)
         |> assign(:theme, theme)}

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

  # We no longer need the generate_qr_preview function as we're using the QRCode component
end
