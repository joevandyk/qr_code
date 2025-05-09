defmodule QrCode.Repo.Migrations.CreateOrdersTable do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :qr_request_id, references(:qr_requests, on_delete: :restrict), null: false
      add :status, :string, null: false
      add :amount_cents, :integer, null: false
      add :currency, :string, null: false, default: "USD"
      add :checkout_session_id, :string
      add :payment_intent_id, :string
      add :customer_id, :string
      add :metadata, :map
      add :email, :string
      add :error_message, :string
      add :idempotency_key, :string

      timestamps()
    end

    create index(:orders, [:qr_request_id])
    create index(:orders, [:checkout_session_id])
    create index(:orders, [:payment_intent_id])
    create unique_index(:orders, [:idempotency_key])
  end
end
