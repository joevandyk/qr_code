defmodule Mix.Tasks.GenerateSamples do
  use Mix.Task
  require Logger
  alias LockScreenQRCode.Templates
  alias LockScreenQRCode.Compositor

  @shortdoc "Generates sample images for all templates"
  def run(_) do
    # Start the application
    Application.ensure_all_started(:lock_screen_qr_code)

    # Set log level for cleaner output
    Logger.configure(level: :info)

    # Create output directory
    output_dir = "sample_images"
    File.mkdir_p!(output_dir)

    # Phone dimensions - create samples for iPhone and common Android sizes
    iphone_dimensions = [width: 1170, height: 2532] # iPhone 12/13 Pro
    android_dimensions = [width: 1080, height: 2340] # Common Android

    # Sample URL and text
    url = "https://example.com/sample"
    text = "Sample QR Code"

    # Get all templates and generate samples
    templates = Templates.all()

    Logger.info("Generating #{length(templates)} sample images for each device type...")

    # Track success/failure for iPhone samples
    Logger.info("Generating iPhone samples...")
    iphone_results = generate_for_device(templates, url, text, iphone_dimensions, Path.join(output_dir, "iphone"))

    # Track success/failure for Android samples
    Logger.info("Generating Android samples...")
    android_results = generate_for_device(templates, url, text, android_dimensions, Path.join(output_dir, "android"))

    # Flatten results
    results = iphone_results ++ android_results

    # Summary
    success_count = Enum.count(results, fn result -> match?({:ok, _}, result) end)
    failure_count = Enum.count(results) - success_count

    if success_count > 0 do
      Logger.info("Successfully generated #{success_count} sample images in directory: #{output_dir}")
    end

    if failure_count > 0 do
      Logger.warning("Failed to generate #{failure_count} sample images")

      # List failures
      Enum.each(results, fn
        {:error, template_id, reason} ->
          Logger.warning("  - #{template_id}: #{inspect(reason)}")
        _ ->
          :ok
      end)
    end
  end

  # Helper to generate images for a specific device type
  defp generate_for_device(templates, url, text, dimensions, output_dir) do
    # Ensure directory exists
    File.mkdir_p!(output_dir)

    # Generate samples for each template
    Enum.map(templates, fn template ->
      template_id = template.id
      output_path = Path.join(output_dir, "#{template_id}.png")

      Logger.info("Generating sample for template: #{template.name}...")

      case Compositor.compose(url, template_id, [text: text] ++ dimensions) do
        {:ok, binary} ->
          # Write to a file
          File.write!(output_path, binary)
          Logger.info("✓ Created #{output_path} (#{byte_size(binary)} bytes)")
          {:ok, template_id}

        {:error, reason} ->
          Logger.error("✗ Failed to generate sample for #{template_id}: #{inspect(reason)}")
          {:error, template_id, reason}
      end
    end)
  end
end
