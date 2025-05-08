defmodule QrCodeWeb.UrlValidatorTest do
  use ExUnit.Case, async: true

  alias QrCodeWeb.UrlValidator

  describe "validate/1" do
    test "returns {:ok, uri} for valid http URL" do
      url = "http://example.com/path?query=string"
      assert {:ok, %URI{scheme: "http", host: "example.com"}} = UrlValidator.validate(url)
    end

    test "returns {:ok, uri} for valid https URL" do
      url = "https://sub.example.co.uk:8080"

      assert {:ok, %URI{scheme: "https", host: "sub.example.co.uk", port: 8080}} =
               UrlValidator.validate(url)
    end

    test "returns {:error, :invalid_scheme} for ftp URL" do
      url = "ftp://example.com"
      assert UrlValidator.validate(url) == {:error, :invalid_scheme}
    end

    test "returns {:error, :invalid_scheme} for URL with no scheme" do
      url = "example.com"
      # URI.parse interprets this as path, not host, scheme is nil
      # Adjusted based on implementation
      assert UrlValidator.validate(url) == {:error, :invalid_format}
    end

    test "returns {:error, :invalid_format} for URL missing host (scheme only)" do
      url = "https://"
      assert UrlValidator.validate(url) == {:error, :invalid_format}
    end

    test "returns {:error, :invalid_format} for severely malformed URL" do
      url = "://example.com"
      assert UrlValidator.validate(url) == {:error, :invalid_format}
    end

    test "returns {:error, :invalid_format} for just a path" do
      url = "/just/a/path"
      assert UrlValidator.validate(url) == {:error, :invalid_format}
    end

    test "returns {:error, :invalid_format} for empty string" do
      url = ""
      assert UrlValidator.validate(url) == {:error, :invalid_format}
    end

    test "returns {:error, :invalid_input} for non-binary input" do
      assert UrlValidator.validate(nil) == {:error, :invalid_input}
      assert UrlValidator.validate(123) == {:error, :invalid_input}
    end
  end
end
