defmodule LockScreenQRCode.Repo do
  use Ecto.Repo,
    otp_app: :lock_screen_qr_code,
    adapter: Ecto.Adapters.Postgres
end
