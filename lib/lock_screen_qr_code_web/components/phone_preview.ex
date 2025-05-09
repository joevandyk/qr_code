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
        url="https://example.com"
        display_text="Scan to connect"
        theme="dark"
        template="pop_vibes"
        gradient="from-pink-400 to-purple-500"
      />

  ## Attributes

    * `url` - The URL for the QR code
    * `display_text` - The text to display above the QR code
    * `theme` - The theme (light or dark)
    * `template` - The template ID
    * `gradient` - The gradient classes for the background
  """
  attr :url, :string, required: true
  attr :display_text, :string, default: "Scan to connect"
  attr :theme, :string, default: "dark"
  attr :template, :string, default: nil
  attr :gradient, :string, required: true
  attr :class, :string, default: "w-60 lg:w-64"

  def phone_preview(assigns) do
    # Get current time for the preview
    datetime = DateTime.now!("Etc/UTC")
    time = Calendar.strftime(datetime, "%H:%M")
    date = Calendar.strftime(datetime, "%A, %B %d")

    assigns = assign(assigns, time: time, date: date)

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
              <.qr_code
                url={@url}
                class="qr-code w-full h-full"
                color="var(--qr-code-color)"
                background="transparent"
                scale={5}
              />
            </div>
          </div>
        </div>

        <!-- Bottom line (fixed position) -->
        <div class="absolute bottom-8 left-0 right-0 flex justify-center">
          <div class="bottom-line h-1 w-32 rounded-full"></div>
        </div>
      </div>
    </.device_mockup>
    """
  end
end
