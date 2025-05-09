defmodule QrCode.Requests do
  @moduledoc """
  The Requests context - handles operations related to QR code requests and orders.
  """

  import Ecto.Query, warn: false
  alias QrCode.Repo
  alias QrCode.QrRequest
  alias QrCode.Order

  @doc """
  Creates a QR request.

  ## Examples

      iex> create_qr_request(%{url: "https://example.com"})
      {:ok, %QrRequest{}}

      iex> create_qr_request(%{url: nil})
      {:error, %Ecto.Changeset{}}

  """
  def create_qr_request(attrs \\ %{}) do
    attrs = Map.put_new(attrs, :token, QrRequest.generate_token())

    %QrRequest{}
    |> QrRequest.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single QR request by its ID.

  Returns nil if the QR request does not exist.

  ## Examples

      iex> get_qr_request(123)
      %QrRequest{}

      iex> get_qr_request(456)
      nil

  """
  def get_qr_request(id) when is_integer(id) do
    Repo.get(QrRequest, id)
  end

  @doc """
  Gets a single QR request by its token.

  Returns nil if the QR request does not exist.

  ## Examples

      iex> get_qr_request_by_token("abc123")
      %QrRequest{}

      iex> get_qr_request_by_token("nonexistent")
      nil

  """
  def get_qr_request_by_token(token) when is_binary(token) do
    Repo.get_by(QrRequest, token: token)
  end

  @doc """
  Updates a QR request.

  ## Examples

      iex> update_qr_request(qr_request, %{template: "pop_vibes"})
      {:ok, %QrRequest{}}

      iex> update_qr_request(qr_request, %{url: nil})
      {:error, %Ecto.Changeset{}}

  """
  def update_qr_request(%QrRequest{} = qr_request, attrs) do
    # Log the qr_request and attrs for debugging
    IO.inspect(qr_request, label: "QR REQUEST BEFORE UPDATE")
    IO.inspect(attrs, label: "UPDATE ATTRIBUTES")

    # Create and print the changeset before update
    changeset = QrRequest.changeset(qr_request, attrs)
    IO.inspect(changeset.changes, label: "CHANGESET CHANGES")

    # Update the record
    result = Repo.update(changeset)

    # Log the result
    case result do
      {:ok, updated} ->
        IO.inspect(updated, label: "UPDATED QR REQUEST")
      {:error, error_changeset} ->
        IO.inspect(error_changeset.errors, label: "UPDATE ERRORS")
    end

    result
  end

  @doc """
  Creates an order for a QR request.

  ## Examples

      iex> create_order(qr_request, %{amount_cents: 500})
      {:ok, %Order{}}

  """
  def create_order(%QrRequest{} = qr_request, attrs \\ %{}) do
    %Order{}
    |> Order.changeset(Map.put(attrs, :qr_request_id, qr_request.id))
    |> Repo.insert()
  end

  @doc """
  Gets an order by its ID.

  ## Examples

      iex> get_order(123)
      %Order{}

      iex> get_order(456)
      nil

  """
  def get_order(id), do: Repo.get(Order, id)

  @doc """
  Updates an order.

  ## Examples

      iex> update_order(order, %{status: :paid})
      {:ok, %Order{}}

  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end
end
