defmodule LockScreenQRCode.Factories do
  @moduledoc """
  Factory functions for creating test data.
  """
  alias LockScreenQRCode.Requests

  @doc """
  Creates a QR request with the given attributes.

  ## Examples

      iex> create_qr_request(%{url: "https://example.com"})
      {:ok, %Requests.QRRequest{}}

  """
  def create_qr_request(attrs \\ %{}) do
    # Generate a token if one isn't provided
    attrs = Map.put_new(attrs, :token, generate_token())

    # Create the QR request
    Requests.create_qr_request(attrs)
  end

  @doc """
  Creates a QR request with the given attributes and returns it directly.
  Raises an error if creation fails.

  ## Examples

      iex> build_qr_request(%{url: "https://example.com"})
      %Requests.QRRequest{}

  """
  def build_qr_request(attrs \\ %{}) do
    case create_qr_request(attrs) do
      {:ok, qr_request} -> qr_request
      {:error, changeset} -> raise "Failed to build QR request: #{inspect(changeset.errors)}"
    end
  end

  # Helper function to generate a random token for QR requests
  defp generate_token do
    length = 10
    alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    for _ <- 1..length, into: "", do: <<Enum.random(String.to_charlist(alphabet))>>
  end
end
