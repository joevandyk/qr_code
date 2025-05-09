defmodule LockScreenQRCode.Compositor do
  @moduledoc """
  Service module for compositing QR codes with templates to create lock screen images.
  """
  require Logger
  alias LockScreenQRCode.Generator
  alias LockScreenQRCode.Templates

  @doc """
  Composes a QR code with a template to create a final lock screen image.

  ## Parameters
    * `url` - The URL to encode in the QR code
    * `template_id` - The ID of the template to use
    * `opts` - Additional options

  ## Options
    * `:preview` - Whether to add a watermark (default: false)
    * `:width` - Width of the output image (default: 1170)
    * `:height` - Height of the output image (default: 2532)
    * `:text` - Text to display above the QR code (default: nil)

  ## Returns
    * `{:ok, binary}` - The binary data of the composed image
    * `{:error, reason}` - Error reason
  """
  def compose(url, template_id, opts \\ []) do
    Logger.debug("Composing QR code for URL: #{url} with template: #{template_id}")
    preview = Keyword.get(opts, :preview, false)
    width = Keyword.get(opts, :width, 1170)
    height = Keyword.get(opts, :height, 2532)
    text = Keyword.get(opts, :text)

    # Validate URL
    if String.trim(url) == "" do
      {:error, "Invalid URL: URL cannot be empty"}
    else
      # Step 1: Generate the QR code with standard colors (safe default)
      Logger.debug("Generating QR code...")
      case Generator.generate(url, scale: 20) do
        {:ok, qr_binary} ->
          Logger.debug("QR code generated successfully, size: #{byte_size(qr_binary)} bytes")

          # Step 2: Get template info
          Logger.debug("Getting template info for: #{template_id}")
          case get_template_info(template_id) do
            {:ok, template_info} ->
              Logger.debug("Template info retrieved: #{inspect(template_info)}")

              # Step 3: Create the composite image
              Logger.debug("Creating composite image...")
              case create_composite_image(qr_binary, template_info, %{
                width: width,
                height: height,
                text: text,
                preview: preview
              }) do
                {:ok, final_binary} ->
                  Logger.debug("Composite image created successfully, size: #{byte_size(final_binary)} bytes")
                  {:ok, final_binary}
                {:error, reason} = error ->
                  Logger.error("Failed to create composite image: #{inspect(reason)}")
                  error
              end

            {:error, reason} = error ->
              Logger.error("Failed to get template info: #{inspect(reason)}")
              error
          end

        {:error, reason} = error ->
          Logger.error("Failed to generate QR code: #{inspect(reason)}")
          error
      end
    end
  end

  @doc """
  Get template information for a given template ID.

  ## Parameters
    * `template_id` - The ID of the template

  ## Returns
    * `{:ok, map}` - Template information
    * `{:error, reason}` - Error reason
  """
  def get_template_info(template_id) do
    case Templates.get(template_id) do
      nil -> {:error, "Template not found: #{template_id}"}
      template -> {:ok, template}
    end
  end

  @doc """
  Creates a composite image with a gradient background, QR code, and optional text.

  ## Parameters
    * `qr_binary` - The binary data of the QR code
    * `template_info` - Template information
    * `opts` - Additional options

  ## Returns
    * `{:ok, binary}` - The binary data of the composed image
    * `{:error, reason}` - Error reason
  """
  def create_composite_image(qr_binary, template_info, opts) do
    try do
      # Create temporary files
      temp_dir = System.tmp_dir!()
      qr_path = Path.join(temp_dir, "qr_code_#{:os.system_time(:millisecond)}.png")
      output_path = Path.join(temp_dir, "output_#{:os.system_time(:millisecond)}.png")

      Logger.debug("Writing QR code to temp file: #{qr_path}")
      # Write QR code to temp file
      File.write!(qr_path, qr_binary)

      # Create base image with gradient background
      gradient = String.replace(template_info.gradient, "from-", "")
      gradient = String.replace(gradient, "to-", "")
      gradient = String.replace(gradient, "via-", "")

      # Split the gradient into components and take the first and last
      gradient_parts = String.split(gradient, " ")
      start_color = List.first(gradient_parts)
      end_color = List.last(gradient_parts)

      Logger.debug("Processing gradient colors: start=#{start_color}, end=#{end_color}")

      # Convert Tailwind color names to hex codes
      start_hex = tailwind_to_hex(start_color)
      end_hex = tailwind_to_hex(end_color)

      # Create a vertical gradient (top to bottom) to match the web preview
      Logger.debug("Creating vertical gradient from #{start_hex} to #{end_hex}")

      # Create image with ImageMagick - using vertical gradient (top to bottom)
      args = [
        "-size", "#{opts.height}x#{opts.width}",  # Swap width and height
        "gradient:#{start_hex}-#{end_hex}",
        "-rotate", "90",  # Rotate to get portrait orientation
        "-resize", "#{opts.width}x#{opts.height}!", # Resize to correct dimensions
        output_path
      ]

      Logger.debug("Running convert command: convert #{Enum.join(args, " ")}")
      {cmd_output, exit_code} = System.cmd("convert", args, stderr_to_stdout: true)

      if exit_code != 0 do
        Logger.error("ImageMagick convert command failed with exit code #{exit_code}: #{cmd_output}")
        raise "ImageMagick failed: #{cmd_output}"
      end

      # Add the QR code to the center, preserving transparency
      qr_size = 800 # Make QR code slightly larger to match web preview

      # Add a white background square for the QR code for better visibility
      overlay_args = [
        output_path,
        # First create a white square for QR code background - centered properly
        "-size", "#{qr_size}x#{qr_size}",
        "xc:white",
        "-gravity", "center",
        "-geometry", "+0+100", # Slight offset down
        "-composite",
        # Then overlay the QR code on top
        qr_path,
        "-gravity", "center",
        "-geometry", "#{qr_size-40}x#{qr_size-40}+0+100", # Slightly smaller than the white background
        "-composite"
      ]

      # Add text if provided - position it higher like in the web preview
      overlay_args = if opts.text do
        Logger.debug("Adding text overlay: #{opts.text}")
        overlay_args ++ [
          "-gravity", "North",
          "-pointsize", "65", # Slightly smaller text for better fit
          "-fill", "white",
          "-size", "#{opts.width-100}x", # Add width constraint with padding
          "-background", "transparent",
          "-gravity", "Center",
          "-interline-spacing", "10", # Add space between lines
          "caption:#{opts.text}", # Use caption: instead of annotate for auto-wrapping
          "-gravity", "North",
          "-geometry", "+0+200", # Position text near top of image
          "-composite",
        ]
      else
        overlay_args
      end

      # Add preview watermark if requested
      overlay_args = if opts.preview do
        Logger.debug("Adding preview watermark")
        overlay_args ++ [
          "-gravity", "SouthEast",
          "-pointsize", "20",
          "-fill", "white",
          "-annotate", "+20+20", "PREVIEW",
        ]
      else
        overlay_args
      end

      # Add final output path
      overlay_args = overlay_args ++ [output_path]

      Logger.debug("Running overlay command: convert #{Enum.join(overlay_args, " ")}")
      {overlay_output, overlay_exit_code} = System.cmd("convert", overlay_args, stderr_to_stdout: true)

      if overlay_exit_code != 0 do
        Logger.error("ImageMagick overlay command failed with exit code #{overlay_exit_code}: #{overlay_output}")
        raise "ImageMagick overlay failed: #{overlay_output}"
      end

      # Read the output file
      Logger.debug("Reading output file: #{output_path}")
      result = File.read!(output_path)
      Logger.debug("Output file read successfully, size: #{byte_size(result)} bytes")

      # Clean up temporary files
      File.rm(qr_path)
      File.rm(output_path)

      {:ok, result}
    rescue
      e ->
        Logger.error("Failed to create composite image: #{inspect(e)}")
        {:error, "Failed to create composite image: #{inspect(e)}"}
    end
  end

  # Map of Tailwind color names to hex codes (simplified for common colors)
  defp tailwind_to_hex(color) do
    colors = %{
      "gray-50" => "#F9FAFB",
      "gray-400" => "#9CA3AF",
      "gray-600" => "#4B5563",
      "gray-800" => "#1F2937",
      "gray-900" => "#111827",
      "white" => "#FFFFFF",
      "pink-400" => "#F472B6",
      "pink-500" => "#EC4899",
      "pink-600" => "#DB2777",
      "purple-500" => "#A855F7",
      "purple-600" => "#9333EA",
      "indigo-900" => "#312E81",
      "blue-500" => "#3B82F6",
      "blue-900" => "#1E3A8A",
      "teal-400" => "#2DD4BF",
      "teal-600" => "#0D9488",
      "emerald-400" => "#34D399",
      "green-400" => "#4ADE80",
      "green-600" => "#16A34A",
      "lime-400" => "#A3E635",
      "lime-600" => "#65A30D",
      "yellow-400" => "#FACC15",
      "yellow-500" => "#EAB308",
      "amber-500" => "#F59E0B",
      "amber-700" => "#B45309",
      "orange-500" => "#F97316",
      "red-400" => "#F87171",
      "rose-400" => "#FB7185",
      "rose-500" => "#F43F5E"
    }

    Map.get(colors, color, "#777777") # Default gray if color not found
  end
end
