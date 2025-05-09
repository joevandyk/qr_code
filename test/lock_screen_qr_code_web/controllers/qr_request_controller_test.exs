defmodule LockScreenQRCodeWeb.QrRequestControllerTest do
  use LockScreenQRCodeWeb.ConnCase, async: true

  test "GET /start creates a QR request and stores token in session", %{conn: conn} do
    conn = get(conn, ~p"/start")

    # Should redirect to create page
    assert redirected_to(conn) == ~p"/create"

    # Session should contain qr_request_token
    assert token = get_session(conn, "qr_request_token")
    assert is_binary(token)

    # Verify the token points to a real record
    assert %LockScreenQRCode.QrRequest{} =
             LockScreenQRCode.Requests.get_qr_request_by_token(token)
  end
end
