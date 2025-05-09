defmodule QrCode.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias QrCode.QrRequest

  @status_values ~w(pending paid failed refunded)a

  schema "orders" do
    field :status, Ecto.Enum, values: @status_values, default: :pending
    field :amount_cents, :integer
    field :currency, :string, default: "USD"
    field :checkout_session_id, :string
    field :payment_intent_id, :string
    field :customer_id, :string
    field :metadata, :map, default: %{}
    field :email, :string
    field :error_message, :string
    field :idempotency_key, :string

    belongs_to :qr_request, QrRequest

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [
      :qr_request_id,
      :status,
      :amount_cents,
      :currency,
      :checkout_session_id,
      :payment_intent_id,
      :customer_id,
      :metadata,
      :email,
      :error_message,
      :idempotency_key
    ])
    |> validate_required([:qr_request_id, :status, :amount_cents, :currency])
    |> foreign_key_constraint(:qr_request_id)
    |> unique_constraint(:idempotency_key)
    |> validate_format(:email, ~r/^[\w.+-]+@[\w-]+\.\w+$/,
      message: "must be a valid email address"
    )
  end
end
