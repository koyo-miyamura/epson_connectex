defmodule EpsonConnect do
  @moduledoc """
  EpsonConnect common API wrapper

  For details, refer to the API document below:
  https://developer.cp.epson.com/ecapi/downloads/?lang=ja
  """

  def host(), do: "https://api.epsonconnect.com"
  def root(), do: "/api/1/printing"

  @doc """
  Build data for EpsonConnect authorize API

  ## Examples
    iex> EpsonConnect.Print.build_authorize(%{username: "dummy_user", password: "dummy_pw", basic_credentials: "dummy_credencials"})
    %{"body" => "grant_type=password&password=dummy_pw&username=dummy_user", "header" => ["Content-Type": "application/x-www-form-urlencoded; charset=utf-8", Authorization: "Basic dummy_credencials"], "host" => "https://api.epsonconnect.com", "path" => "/api/1/printing/oauth2/auth/token?subject=printer"}
  """
  def build_authorize( %{ username: username, password: password, basic_credentials: basic_credentials } ) do
    %{
      "host"   => EpsonConnect.host(),
      "path"   => Path.join( EpsonConnect.root(), "/oauth2/auth/token?subject=printer" ),
      "body"   => %{
        "grant_type" => "password",
        "username"   => username,
        "password"   => password,
      } |> URI.encode_query,
      "header" => [
        "Content-Type":  "application/x-www-form-urlencoded; charset=utf-8",
        "Authorization": "Basic #{basic_credentials}"
      ],
    }
  end
end
