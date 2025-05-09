defmodule QrCode.Repo.Migrations.CreateQrRequestsTable do
  use Ecto.Migration

  def change do
    create table(:qr_requests) do
      add :url, :string, null: false
      add :name, :string
      add :token, :string, null: false
      add :template, :string
      add :preview_image_url, :string

      timestamps()
    end

    create unique_index(:qr_requests, [:token])
  end
end
