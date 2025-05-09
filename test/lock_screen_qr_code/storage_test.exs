defmodule LockScreenQRCode.StorageTest do
  use LockScreenQRCode.DataCase, async: true
  alias LockScreenQRCode.Storage

  setup do
    # Create a binary image for testing
    binary = <<137, 80, 78, 71, 13, 10, 26, 10>> # PNG header

    # Generate a unique key for each test
    key = "test_#{:rand.uniform(1000000)}"

    # Return the key and binary
    %{key: key, binary: binary}
  end

  describe "store/3" do
    test "stores a binary image and returns a URL", %{key: key, binary: binary} do
      assert {:ok, url} = Storage.store(key, binary)
      assert is_binary(url)
      assert String.starts_with?(url, "/generated/")
      assert String.ends_with?(url, ".png")
    end
  end

  describe "retrieve/1" do
    test "retrieves a stored binary image", %{key: key, binary: binary} do
      {:ok, _url} = Storage.store(key, binary)

      assert {:ok, retrieved_binary} = Storage.retrieve(key)
      assert retrieved_binary == binary
    end

    test "returns error when image does not exist" do
      assert {:error, :not_found} = Storage.retrieve("nonexistent_key")
    end
  end

  describe "delete/1" do
    test "deletes a stored image", %{key: key, binary: binary} do
      {:ok, _url} = Storage.store(key, binary)

      assert :ok = Storage.delete(key)
      assert {:error, :not_found} = Storage.retrieve(key)
    end

    test "returns ok when image does not exist" do
      assert :ok = Storage.delete("nonexistent_key")
    end
  end

  describe "generate_signed_url/2" do
    test "generates a URL for a stored image", %{key: key, binary: binary} do
      {:ok, _url} = Storage.store(key, binary)

      assert {:ok, signed_url} = Storage.generate_signed_url(key)
      assert is_binary(signed_url)
      assert String.contains?(signed_url, key)
    end
  end
end
