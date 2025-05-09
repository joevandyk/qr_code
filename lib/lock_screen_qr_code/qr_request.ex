defmodule LockScreenQRCode.QrRequest do
  @moduledoc """
  Schema and changesets for QR code requests.

  This module defines the QrRequest schema along with the necessary validation and helper functions.
  QrRequests represent user-submitted URLs that will be converted to QR codes.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias LockScreenQRCode.Order

  schema "qr_requests" do
    field :url, :string
    field :name, :string
    field :token, :string
    field :template, :string
    field :preview_image_url, :string

    has_many :orders, Order

    timestamps()
  end

  @doc false
  def changeset(qr_request, attrs) do
    qr_request
    |> cast(attrs, [:url, :name, :token, :template, :preview_image_url])
    |> validate_required([:url, :token])
    |> validate_url(:url)
    |> unique_constraint(:token)
  end

  @doc """
  Validates that a string is a valid URL
  """
  def validate_url(changeset, field) do
    validate_change(changeset, field, fn _, url ->
      case URI.parse(url) do
        %URI{scheme: nil} ->
          [{field, "is missing a scheme (e.g. https://)"}]

        %URI{host: nil} ->
          [{field, "is missing a host"}]

        %URI{scheme: scheme} when scheme not in ["http", "https"] ->
          [{field, "scheme must be http or https"}]

        _ ->
          []
      end
    end)
  end

  @doc """
  Generates a secure random token for the QR request
  """
  def generate_token do
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64(padding: false)
  end
end
