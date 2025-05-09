defmodule LockScreenQRCode.Storage do
  @moduledoc """
  Service module for storing and retrieving generated images.
  """
  require Logger

  @doc """
  Stores an image binary with the given key.

  ## Parameters
    * `key` - The unique key for the image
    * `binary` - The binary data of the image
    * `opts` - Additional options

  ## Options
    * `:content_type` - The content type of the image (default: "image/png")
    * `:ttl` - Time-to-live in seconds (default: 86400 - 24 hours)

  ## Returns
    * `{:ok, url}` - The URL where the image can be accessed
    * `{:error, reason}` - Error reason
  """
  def store(key, binary, opts \\ []) do
    content_type = Keyword.get(opts, :content_type, "image/png")
    _ttl = Keyword.get(opts, :ttl, 86400)

    Logger.info("Storing image with key: #{key}, size: #{byte_size(binary)} bytes, type: #{content_type}")

    # In a real implementation, this would upload to S3 or another storage service
    # For now, we'll save to the local filesystem in a temporary directory
    try do
      # Ensure the temporary directory exists
      File.mkdir_p!("priv/static/generated")

      # Generate a filename based on the key
      ext = get_file_extension(content_type)
      filename = "#{key}#{ext}"
      path = "priv/static/generated/#{filename}"

      # Write the file
      File.write!(path, binary)

      # Return a URL to access the file
      url = "/generated/#{filename}"
      Logger.info("Image stored successfully at: #{url}")
      {:ok, url}
    rescue
      e ->
        Logger.error("Failed to store image: #{inspect(e)}")
        {:error, "Failed to store image: #{inspect(e)}"}
    end
  end

  @doc """
  Retrieves an image binary with the given key.

  ## Parameters
    * `key` - The unique key for the image
    * `opts` - Additional options

  ## Options
    * `:content_type` - The content type of the image (default: "image/png")

  ## Returns
    * `{:ok, binary}` - The binary data of the image
    * `{:error, reason}` - Error reason
  """
  def retrieve(key, opts \\ []) do
    content_type = Keyword.get(opts, :content_type, "image/png")
    Logger.info("Retrieving image with key: #{key}, type: #{content_type}")

    # In a real implementation, this would download from S3 or another storage service
    # For now, we'll read from the local filesystem
    try do
      ext = get_file_extension(content_type)
      path = "priv/static/generated/#{key}#{ext}"

      if File.exists?(path) do
        binary = File.read!(path)
        Logger.info("Image retrieved successfully, size: #{byte_size(binary)} bytes")
        {:ok, binary}
      else
        Logger.error("Image not found: #{path}")
        {:error, :not_found}
      end
    rescue
      e ->
        Logger.error("Failed to retrieve image: #{inspect(e)}")
        {:error, "Failed to retrieve image: #{inspect(e)}"}
    end
  end

  @doc """
  Deletes an image with the given key.

  ## Parameters
    * `key` - The unique key for the image
    * `opts` - Additional options

  ## Options
    * `:content_type` - The content type of the image (default: "image/png")

  ## Returns
    * `:ok` - The image was deleted successfully
    * `{:error, reason}` - Error reason
  """
  def delete(key, opts \\ []) do
    content_type = Keyword.get(opts, :content_type, "image/png")
    Logger.info("Deleting image with key: #{key}, type: #{content_type}")

    # In a real implementation, this would delete from S3 or another storage service
    # For now, we'll delete from the local filesystem
    try do
      ext = get_file_extension(content_type)
      path = "priv/static/generated/#{key}#{ext}"

      if File.exists?(path) do
        File.rm!(path)
        Logger.info("Image deleted successfully")
        :ok
      else
        Logger.warning("Image not found for deletion: #{path}")
        :ok
      end
    rescue
      e ->
        Logger.error("Failed to delete image: #{inspect(e)}")
        {:error, "Failed to delete image: #{inspect(e)}"}
    end
  end

  @doc """
  Generates a signed URL for accessing an image with the given key.

  ## Parameters
    * `key` - The unique key for the image
    * `opts` - Additional options

  ## Options
    * `:ttl` - Time-to-live in seconds (default: 3600 - 1 hour)
    * `:content_type` - The content type of the image (default: "image/png")

  ## Returns
    * `{:ok, url}` - The signed URL where the image can be accessed
    * `{:error, reason}` - Error reason
  """
  def generate_signed_url(key, opts \\ []) do
    _ttl = Keyword.get(opts, :ttl, 3600)
    content_type = Keyword.get(opts, :content_type, "image/png")

    Logger.info("Generating signed URL for image with key: #{key}, type: #{content_type}")

    # In a real implementation, this would generate a signed URL with the storage service
    # For now, we'll just return a simple URL
    ext = get_file_extension(content_type)
    url = "/generated/#{key}#{ext}"
    Logger.info("Signed URL generated: #{url}")
    {:ok, url}
  end

  # Helper function to get file extension from content type
  defp get_file_extension(content_type) do
    case content_type do
      "image/png" -> ".png"
      "image/jpeg" -> ".jpg"
      "image/jpg" -> ".jpg"
      "image/gif" -> ".gif"
      "image/webp" -> ".webp"
      _ -> ".png" # Default to png
    end
  end
end
