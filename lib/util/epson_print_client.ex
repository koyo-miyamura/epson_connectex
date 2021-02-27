defmodule EpsonPrint.Client do
  @moduledoc """
  EpsonConnect API wrapper

  For details, refer to the API document below:
  https://developer.cp.epson.com/ecapi/downloads/?lang=ja
  """

  @host "https://api.epsonconnect.com"
  @root "/api/1/printing"

  @doc """
  Build data for EpsonConnect authorize API

  ## Examples
    iex> EpsonPrint.Client.build_authorize(%{username: "dummy_user", password: "dummy_pw", basic_credentials: "dummy_credencials"})
    %{"body" => "grant_type=password&password=dummy_pw&username=dummy_user", "header" => ["Content-Type": "application/x-www-form-urlencoded; charset=utf-8", Authorization: "Basic dummy_credencials"], "host" => "https://api.epsonconnect.com", "path" => "/api/1/printing/oauth2/auth/token?subject=printer"}
  """
  def build_authorize( %{ username: username, password: password, basic_credentials: basic_credentials } ) do
    %{
      "host"   => @host,
      "path"   => Path.join( @root, "/oauth2/auth/token?subject=printer" ),
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

  @doc """
  Build data for EpsonConnect create job API

  ## Examples
    iex> EpsonPrint.Client.build_create_job(%{"dummy_job_key" => 123}, %{"subject_id" => 456, "access_token"=> 789})
    %{"body" => ~s({"dummy_job_key":123}), "header" => ["Content-Type": "application/json; charset=utf-8", Authorization: "Bearer 789"], "host" => "https://api.epsonconnect.com", "path" => "/api/1/printing/printers/456/jobs"}
  """
  def build_create_job( payload, %{ "subject_id" => printer_id, "access_token" => access_token } ) do
    %{
      "host"   => @host,
      "path"   => Path.join( @root, "/printers/#{ printer_id }/jobs" ),
      "body"   => payload |> Jason.encode!,
      "header" => header_json() |> Keyword.merge( header_oauth2( access_token ) ),
    }
  end

  @doc """
  Build data for EpsonConnect upload file API

  ## Examples
    iex> EpsonPrint.Client.build_upload(%{"upload_uri"=>"https://dummy.upload_uri.com/dummy_path"}, "dummy_from_filename", "dummy_to_filename")
    %{"body" => "dummy_from_filename", "header" => ["Content-Type": "application/octet-stream"], "host" => "https://dummy.upload_uri.com/dummy_path", "path" => "&File=dummy_to_filename"}
  """
  def build_upload( %{ "upload_uri" => upload_uri }, file_body, to_filename ) do
    %{
      "host"   => upload_uri,
      "path"   => "&File=#{ to_filename }",
      "body"   => file_body,
      "header" => [
        "Content-Type": "application/octet-stream",
      ],
    }
  end

  @doc """
  Build data for EpsonConnect execute print API

  ## Examples
    iex> EpsonPrint.Client.build_print(%{"id" => "dummy_job_id"}, %{"subject_id" => "dummy_printer_id", "access_token" => "dummy_access_token"})
    %{"body" => "", "header" => ["Content-Type": "application/json; charset=utf-8", Authorization: "Bearer dummy_access_token"], "host" => "https://api.epsonconnect.com", "path" => "/api/1/printing/printers/dummy_printer_id/jobs/dummy_job_id/print"}
  """
  def build_print( %{ "id" => job_id }, %{ "subject_id" => printer_id, "access_token" => access_token } ) do
    %{
      "host"   => @host,
      "path"   => Path.join( @root, "/printers/#{ printer_id }/jobs/#{ job_id }/print" ),
      "body"   => "",
      "header" => Keyword.merge( header_json(), header_oauth2( access_token ) ),
    }
  end

  @doc """
  Build data for get job result API

  ## Examples
    iex> EpsonPrint.Client.build_get_result(%{"id" => "dummy_job_id"}, %{"subject_id" => "dummy_printer_id", "access_token" => "dummy_access_token"})
    %{"body" => "", "header" => [Authorization: "Bearer dummy_access_token"], "host" => "https://api.epsonconnect.com", "path" => "/api/1/printing/printers/dummy_printer_id/jobs/dummy_job_id"}
  """
  def build_get_result( %{ "id" => job_id }, %{ "subject_id" => printer_id, "access_token" => access_token } ) do
    %{
      "host"   => @host,
      "path"   => Path.join( @root, "/printers/#{ printer_id }/jobs/#{ job_id }" ),
      "body"   => "",
      "header" => header_oauth2( access_token ),
    }
  end

  defp header_json, do: [ "Content-Type": "application/json; charset=utf-8" ]
  defp header_oauth2( access_token ), do: [ "Authorization": "Bearer #{ access_token }" ]
end
