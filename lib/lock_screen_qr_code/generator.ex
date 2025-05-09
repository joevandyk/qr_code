defmodule LockScreenQRCode.Generator do
  @moduledoc """
  Service module for generating QR codes using the qr_code library.
  """
  require Logger

  @doc """
  Generates a QR code binary for the given URL.

  ## Options
    * `:format` - Output format, one of :png, :svg (default: :png)
    * `:error_correction` - Error correction level, one of :low, :medium, :quartile, :high (default: :low)
    * `:scale` - Scale factor for the QR code (default: 10)

  ## Returns
    * `{:ok, binary}` - Binary data of the QR code
    * `{:error, reason}` - Error reason
  """
  def generate(url, opts \\ []) do
    # Default options
    format = Keyword.get(opts, :format, :png)
    error_correction = Keyword.get(opts, :error_correction, :low)
    scale = Keyword.get(opts, :scale, 10)

    # Ensure URL has scheme for QR code library
    url = if String.starts_with?(url, ["http://", "https://"]), do: url, else: "https://" <> url

    Logger.info("Generating QR code for URL: #{url} (format: #{format}, scale: #{scale})")

    try do
      # Create settings for the renderer
      settings = case format do
        :png ->
          %QRCode.Render.PngSettings{
            scale: scale,
            background_color: "#ffffff",
            qrcode_color: "#000000"
          }

        :svg ->
          %QRCode.Render.SvgSettings{
            scale: scale,
            background_color: "#ffffff",
            qrcode_color: "#000000"
          }
      end

      # Follow the documented pipeline for QR code generation:
      # 1. Create the QR code
      # 2. Render it to the desired format
      # 3. Convert to base64 or save to file
      result = url
               |> QRCode.create(error_correction)
               |> QRCode.render(format, settings)

      case result do
        {:ok, binary_data} ->
          Logger.debug("QR code generated successfully, size: #{byte_size(binary_data)} bytes")
          {:ok, binary_data}

        {:error, reason} ->
          Logger.error("Failed to generate QR code: #{reason}")
          {:error, reason}
      end
    rescue
      e ->
        Logger.error("QR code generation failed: #{inspect(e)}")
        {:error, "Failed to generate QR code: #{inspect(e)}"}
    end
  end

  @doc """
  Adds a watermark to a QR code binary.

  This is used for preview images before payment.

  ## Returns
    * `{:ok, binary}` - Binary data of the QR code with watermark
    * `{:error, reason}` - Error reason
  """
  def add_preview_watermark(qr_binary) do
    # For now just return the original binary
    # In a real implementation, we would use ImageMagick here to add a watermark
    {:ok, qr_binary}
  end
end
