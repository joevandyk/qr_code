defmodule LockScreenQRCodeWeb.DesignLive do
  use LockScreenQRCodeWeb, :live_view
  require Logger
  alias LockScreenQRCode.Requests
  alias LockScreenQRCode.Templates
  import LockScreenQRCodeWeb.Components.PhonePreview

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:lock_screen_qr_code, :design_live, :mount], %{status: :start})

    # QR request is now always available due to the hook creating one if needed
    if socket.assigns[:qr_request] do
      Logger.info("DesignLive mounted with QR request: #{socket.assigns.qr_request.id}")
    else
      Logger.warning("QR request should have been created by hook but wasn't found")
    end

    templates = Templates.all()

    # Default to the first template if none is selected
    template = socket.assigns[:qr_request].template || List.first(templates).id
    theme = Templates.get_theme(template)

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
        theme = Templates.get_theme(template_id)

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
