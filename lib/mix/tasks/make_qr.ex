defmodule Mix.Tasks.MakeQr do
  use Mix.Task
  require Logger

  @shortdoc "Generates a QR code with specified parameters"
  def run(args) do
    # Start the application to ensure all dependencies are loaded
    Application.ensure_all_started(:lock_screen_qr_code)

    # Parse arguments
    {opts, _, _} = OptionParser.parse(args,
      switches: [
        url: :string,
        template: :string,
        text: :string,
        output: :string
      ],
      aliases: [
        u: :url,
        t: :template,
        n: :text,
        o: :output
      ]
    )

    # Set defaults
    url = Keyword.get(opts, :url, "https://example.com")
    template_id = Keyword.get(opts, :template, "pop_vibes")
    text = Keyword.get(opts, :text, "QR Code")
    output_path = Keyword.get(opts, :output, "qr_output.png")

    Logger.info("Generating QR code:")
    Logger.info("  URL: #{url}")
    Logger.info("  Template: #{template_id}")
    Logger.info("  Text: #{text}")
    Logger.info("  Output: #{output_path}")

    # Generate QR code
    case LockScreenQRCode.Compositor.compose(url, template_id, text: text) do
      {:ok, binary} ->
        # Save to output file
        File.write!(output_path, binary)
        Logger.info("QR code written to #{output_path}, size: #{byte_size(binary)} bytes")

        # Open the file if on macOS
        if String.contains?(System.get_env("OS") || "", "darwin") do
          System.cmd("open", [output_path])
        end

      {:error, reason} ->
        Logger.error("Failed to generate QR code: #{inspect(reason)}")
    end
  end
end
