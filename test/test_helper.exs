ExUnit.start(exclude: [:feature, :skip])
Ecto.Adapters.SQL.Sandbox.mode(LockScreenQRCode.Repo, :manual)

# Configure and start Wallaby
Application.ensure_all_started(:wallaby)
