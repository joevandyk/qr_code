defmodule Mix.Tasks.TestQr do
  use Mix.Task
  require Logger

  @shortdoc "Tests QR code generation"
  def run(_) do
    # Start the application to ensure all dependencies are loaded
    Application.ensure_all_started(:lock_screen_qr_code)

    # Set log level to debug for more detailed output
    Logger.configure(level: :debug)

    # Test parameters
    url = "https://example.com"
    template_id = "pop_vibes"
    text = "Test QR Code"

    Logger.info("Testing QR code generation for URL: #{url}, template: #{template_id}")

    # Create the image
    case LockScreenQRCode.Compositor.compose(url, template_id, text: text) do
      {:ok, binary} ->
        # Write to a test file
        output_path = "test_qr_output.png"
        File.write!(output_path, binary)
        Logger.info("QR code written to #{output_path}, size: #{byte_size(binary)} bytes")

        # Try opening the file
        System.cmd("open", [output_path])

      {:error, reason} ->
        Logger.error("Failed to generate QR code: #{inspect(reason)}")
    end
  end
end
