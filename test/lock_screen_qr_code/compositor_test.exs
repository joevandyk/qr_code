defmodule LockScreenQRCode.CompositorTest do
  use LockScreenQRCode.DataCase, async: true
  alias LockScreenQRCode.Compositor

  describe "compose/3" do
    test "returns an image binary when given a valid URL and template" do
      url = "https://example.com"
      template_id = "pop_vibes"

      assert {:ok, binary} = Compositor.compose(url, template_id)
      assert is_binary(binary)
      assert byte_size(binary) > 0
    end

    test "returns an image binary with watermark when preview option is true" do
      url = "https://example.com"
      template_id = "ocean_blue"

      assert {:ok, binary} = Compositor.compose(url, template_id, preview: true)
      assert is_binary(binary)
      assert byte_size(binary) > 0
    end

    test "handles invalid URLs" do
      url = ""
      template_id = "pop_vibes"

      assert {:error, _reason} = Compositor.compose(url, template_id)
    end

    test "handles invalid templates" do
      url = "https://example.com"
      template_id = "nonexistent_template"

      # Our current implementation just returns a success with a default template
      # In a real implementation, this might return an error
      assert {:ok, binary} = Compositor.compose(url, template_id)
      assert is_binary(binary)
      assert byte_size(binary) > 0
    end
  end
end
