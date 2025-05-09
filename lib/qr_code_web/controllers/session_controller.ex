defmodule QrCodeWeb.SessionController do
  use QrCodeWeb, :controller

  @allowed_keys ~w(qr_request_id)

  def create(conn, params) do
    conn =
      Enum.reduce(params, conn, fn {key, value}, acc_conn ->
        if key in @allowed_keys do
          # Convert string ID to integer if it's the qr_request_id
          value =
            case key do
              "qr_request_id" when is_binary(value) -> String.to_integer(value)
              _ -> value
            end

          put_session(acc_conn, key, value)
        else
          acc_conn
        end
      end)

    json(conn, %{status: "ok"})
  end
end
