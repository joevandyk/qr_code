defmodule LockScreenQRCode.Token do
  @moduledoc """
  Module for generating and verifying session tokens.
  """

  @salt "lock_screen_qr_code_session"
  # 24 hours in seconds
  @token_max_age 86_400

  @doc """
  Generates a token for a QR request.
  """
  def generate_token(qr_request_token) do
    Phoenix.Token.sign(LockScreenQRCodeWeb.Endpoint, @salt, qr_request_token)
  end

  @doc """
  Verifies a session token.
  Returns
  - {:ok, qr_request_token} if valid
  - {:error, reason} otherwise
  """
  def verify_token(token) do
    Phoenix.Token.verify(LockScreenQRCodeWeb.Endpoint, @salt, token, max_age: @token_max_age)
  end
end
