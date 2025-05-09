defmodule QrCodeWeb.UrlValidator do
  @moduledoc """
  Validates URLs to ensure they are well-formed and use http/https schemes.
  """

  @doc """
  Validates the given URL string.

  Returns `{:ok, uri}` if the URL is valid (parsable and uses http/https).
  Returns `{:error, reason}` otherwise.
  """
  def validate(url) when is_binary(url) do
    try do
      uri = URI.parse(url)

      case uri do
        # Case 1: Valid scheme and non-empty host
        %URI{scheme: scheme, host: host}
        when scheme in ["http", "https"] and is_binary(host) and host != "" ->
          {:ok, uri}

        # Case 2: Scheme is present but not http/https
        %URI{scheme: scheme} when not is_nil(scheme) and scheme not in ["http", "https"] ->
          {:error, :invalid_scheme}

        # Case 3: Other invalid formats (nil scheme, empty/nil host etc.)
        _ ->
          {:error, :invalid_format}
      end
    rescue
      # URI.parse can raise for severely malformed URLs
      ArgumentError -> {:error, :invalid_format}
    end
  end

  def validate(_), do: {:error, :invalid_input}
end
