defmodule LockScreenQRCodeWeb.Components.QRCode do
  @moduledoc """
  Component for rendering QR codes with customizable styling.
  """
  use Phoenix.Component
  alias LockScreenQRCode.Generator
  require Logger
  import Phoenix.HTML, only: [raw: 1]

  @doc """
  Renders a QR code as an embedded SVG with customizable styling.

  ## Examples

      <.qr_code url="https://example.com" class="w-32 h-32" color="white" background="transparent" />

  ## Attributes

    * `url` - The URL to encode in the QR code (required)
    * `class` - CSS classes for the SVG (optional)
    * `color` - Color of the QR code (default: "white")
    * `background` - Background color of the QR code (default: "transparent")
    * `scale` - Scale factor for the QR code (default: 6)
  """
  attr :url, :string, required: true
  attr :class, :string, default: ""
  attr :color, :string, default: "white"
  attr :background, :string, default: "transparent"
  attr :scale, :integer, default: 6

  def qr_code(assigns) do
    # Generate the SVG QR code
    qr_result = Generator.generate_svg(assigns.url,
      qr_color: assigns.color,
      background_color: assigns.background,
      scale: assigns.scale
    )

    # Parse the result and prepare SVG for direct embedding
    svg_content = case qr_result do
      {:ok, svg} ->
        # Extract the SVG content without the XML declaration
        # Also ensure the SVG has proper viewBox and preserveAspectRatio attributes
        svg
        |> String.replace(~r/<\?xml.*?\?>/, "")
        |> String.replace(~r/<!DOCTYPE.*?>/, "")
        |> String.replace(~r/<svg/, "<svg preserveAspectRatio=\"xMidYMid meet\"")
        |> String.trim()

      {:error, _reason} ->
        Logger.error("Failed to generate QR code for URL: #{assigns.url}")
        "<svg width=\"100%\" height=\"100%\" viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><text x=\"50%\" y=\"50%\" text-anchor=\"middle\" fill=\"currentColor\">QR Error</text></svg>"
    end

    assigns = assign(assigns, :svg_content, svg_content)

    ~H"""
    <div class={"#{@class} overflow-hidden flex items-center justify-center"}>
      <%= raw(@svg_content) %>
    </div>
    """
  end
end
