defmodule QrCode.Repo do
  use Ecto.Repo,
    otp_app: :qr_code,
    adapter: Ecto.Adapters.Postgres
end
