defmodule LockScreenQRCode.GeneratorTest do
  use ExUnit.Case, async: true
  alias LockScreenQRCode.Generator

  describe "generate/2" do
    test "successfully generates a QR code for a valid URL" do
      url = "https://example.com"

      assert {:ok, qr_binary} = Generator.generate(url)
      assert is_binary(qr_binary)
      assert byte_size(qr_binary) > 0
    end

    test "generates QR code with different sizes" do
      url = "https://example.com"

      assert {:ok, qr_binary_small} = Generator.generate(url, size: 128)
      assert {:ok, qr_binary_large} = Generator.generate(url, size: 512)

      assert byte_size(qr_binary_small) < byte_size(qr_binary_large)
    end

    test "supports both PNG and SVG formats" do
      url = "https://example.com"

      assert {:ok, png_binary} = Generator.generate(url, format: :png)
      assert {:ok, svg_binary} = Generator.generate(url, format: :svg)

      # PNG starts with a specific header
      assert <<137, 80, 78, 71, 13, 10, 26, 10, _::binary>> = png_binary

      # SVG should be XML
      assert svg_binary =~ "<?xml"
      assert svg_binary =~ "<svg"
    end
  end

  describe "add_preview_watermark/1" do
    test "adds watermark to QR code binary" do
      url = "https://example.com"
      {:ok, qr_binary} = Generator.generate(url)

      assert {:ok, watermarked_binary} = Generator.add_preview_watermark(qr_binary)
      assert is_binary(watermarked_binary)
    end
  end
end
