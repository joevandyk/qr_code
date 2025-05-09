defmodule LockScreenQRCode.GeneratorTest do
  use LockScreenQRCode.DataCase
  alias LockScreenQRCode.Generator
  require Logger

  describe "generate/2" do
    test "generates a PNG QR code successfully" do
      url = "https://example.com"

      # Debug the steps for QR code creation
      IO.puts("Creating test QR code...")
      create_result = QRCode.create(url, :low)
      IO.inspect(create_result, label: "QRCode.create result")

      case create_result do
        {:ok, qr} ->
          IO.puts("Successfully created QR code object")

          # Test settings
          settings = %QRCode.Render.PngSettings{
            scale: 10,  # Using a fixed value for testing
            background_color: "#ffffff",
            qrcode_color: "#000000"
          }

          # Debug rendering
          IO.puts("Attempting to render QR code...")
          render_result = qr |> QRCode.render(:png, settings)
          IO.inspect(render_result, label: "QRCode.render result")
          IO.puts("Render result type: #{inspect(render_result.__struct__)}")

          if is_binary(render_result) do
            IO.puts("Render result byte size: #{byte_size(render_result)}")
          else
            IO.puts("Render result is not a binary, it's a #{inspect(render_result.__struct__)}")
          end

          # Now test our Generator module directly
          {:ok, qr_binary} = Generator.generate(url, format: :png)
          assert is_binary(qr_binary)
          assert byte_size(qr_binary) > 0

        {:error, reason} ->
          flunk("QRCode.create failed in test: #{reason}")
      end
    end

    test "handles URLs without scheme" do
      url = "example.com"

      result = Generator.generate(url, format: :png)
      assert {:ok, binary} = result
      assert is_binary(binary)
      assert byte_size(binary) > 0
    end

    test "generates SVG format" do
      url = "https://example.com"

      result = Generator.generate(url, format: :svg)
      assert {:ok, svg} = result
      assert is_binary(svg)
      assert byte_size(svg) > 0
      assert String.starts_with?(svg, "<?xml") or String.starts_with?(svg, "<svg")
    end

    test "handles error cases gracefully" do
      # Test a very long URL that might cause issues
      long_url = String.duplicate("a", 5000) <> ".com"

      result = Generator.generate(long_url)
      # We should either get a valid binary or a proper error
      case result do
        {:ok, binary} ->
          assert is_binary(binary)
          assert byte_size(binary) > 0

        {:error, reason} ->
          assert is_binary(reason)
      end
    end
  end

  describe "add_preview_watermark/1" do
    test "successfully adds watermark to binary" do
      binary = <<1, 2, 3, 4>>

      {:ok, result} = Generator.add_preview_watermark(binary)
      assert is_binary(result)
    end
  end
end
