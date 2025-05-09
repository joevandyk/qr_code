defmodule LockScreenQRCodeWeb.Components.PhonePreview do
  @moduledoc """
  A reusable component that displays a phone mockup with QR code.
  """
  use Phoenix.Component
  import LockScreenQRCodeWeb.Components.QRCode
  import LockScreenQRCodeWeb.Components.DeviceMockup

  @doc """
  Renders a phone preview with a QR code.

  ## Examples

      <.phone_preview
        qr_request={%{url: "https://example.com", name: "Scan to connect", template: "pop_vibes"}}
      />

      # Or with individual parameters
      <.phone_preview
        url="https://example.com"
        display_text="Scan to connect"
        template="pop_vibes"
      />

  ## Attributes

    * `qr_request` - The QR request struct or map containing url, name, and template
    * `url` - The URL for the QR code (alternative to qr_request)
    * `display_text` - The text to display above the QR code (alternative to qr_request)
    * `template` - The template ID (alternative to qr_request)
    * `gradient` - Optional override for the gradient classes
    * `theme` - Optional override for the theme
    * `class` - Additional CSS classes
    * `show_watermark` - Whether to show the preview watermark
  """
  attr :qr_request, :map, default: nil
  attr :url, :string, default: nil
  attr :display_text, :string, default: nil
  attr :template, :string, default: nil
  attr :theme, :string, default: nil
  attr :gradient, :string, default: nil
  attr :class, :string, default: "w-60 lg:w-64"
  attr :show_watermark, :boolean, default: false

  def phone_preview(assigns) do
    # Get current time for the preview
    datetime = DateTime.now!("Etc/UTC")
    time = Calendar.strftime(datetime, "%H:%M")
    date = Calendar.strftime(datetime, "%A, %B %d")

    # Extract values - allow either qr_request or individual params
    url = if assigns.qr_request, do: assigns.qr_request.url, else: assigns.url
    display_text = cond do
      assigns.qr_request && assigns.qr_request.name -> assigns.qr_request.name
      assigns.display_text -> assigns.display_text
      true -> "Scan to connect"
    end
    template_id = if assigns.qr_request, do: assigns.qr_request.template, else: assigns.template

    # Get template info
    template_gradient = if assigns.gradient do
      assigns.gradient
    else
      alias LockScreenQRCode.Templates
      Templates.get_gradient(template_id)
    end

    template_theme = if assigns.theme do
      assigns.theme
    else
      alias LockScreenQRCode.Templates
      Templates.get_theme(template_id)
    end

    # Set QR code color based on theme - use var(--qr-code-color) which is defined in CSS
    # This ensures the QR code color is consistent with the theme
    qr_color = "var(--qr-code-color)"

    # Check if URL is present to avoid errors
    has_valid_url = url && String.trim(url) != ""

    assigns = assign(assigns,
      time: time,
      date: date,
      url: url,
      display_text: display_text,
      theme: template_theme,
      gradient: template_gradient,
      qr_color: qr_color,
      has_valid_url: has_valid_url
    )

    ~H"""
    <.device_mockup color="base" class={@class}>
      <div class={"w-full h-full bg-gradient-to-br relative overflow-hidden #{@gradient}"} data-theme={@theme}>
        <!-- Time at top (fixed position) -->
        <div class="absolute top-8 left-0 right-0 text-center">
          <p class="time text-5xl font-light"><%= @time %></p>
          <p class="date text-sm mt-1"><%= @date %></p>
        </div>

        <!-- QR code container (fixed position with explicit centering) -->
        <div class="absolute inset-0 flex items-center justify-center">
          <div class="flex flex-col items-center w-full">
            <p class="display-text font-bold text-lg mb-6 text-center w-full px-4 drop-shadow-sm"><%= @display_text %></p>

            <!-- QR code with fixed sizing and better containment -->
            <div class="flex items-center justify-center bg-transparent w-56 h-56">
              <%= if @has_valid_url do %>
                <.qr_code
                  url={@url}
                  class="qr-code w-full h-full"
                  color={@qr_color}
                  background="transparent"
                  scale={5}
                />
              <% else %>
                <div class="w-full h-full flex items-center justify-center bg-black/10 rounded-lg">
                  <p class="text-current/50 text-sm">QR Code</p>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <!-- Bottom line (fixed position) -->
        <div class="absolute bottom-8 left-0 right-0 flex justify-center">
          <div class="bottom-line h-1 w-32 rounded-full"></div>
        </div>

        <!-- Preview Watermark (if enabled) -->
        <%= if @show_watermark do %>
          <div class="absolute bottom-4 right-4">
            <p class="text-[8px] font-medium opacity-60 text-current">PREVIEW</p>
          </div>
        <% end %>
      </div>
    </.device_mockup>
    """
  end
end
