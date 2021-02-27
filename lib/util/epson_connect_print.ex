defmodule EpsonConnect.Print do
  @moduledoc """
  EpsonConnect printer API wrapper

  For details, refer to the API document below:
  https://developer.cp.epson.com/ecapi/downloads/?lang=ja
  """

  import EpsonConnect

  def target(), do: "printers"

  @doc """
  Build data for EpsonConnect create job API

  ## Examples
    iex> EpsonConnect.Print.build_create_job(%{"dummy_job_key" => 123}, %{"subject_id" => 456, "access_token"=> 789})
    %{"body" => ~s({"dummy_job_key":123}), "header" => ["Content-Type": "application/json; charset=utf-8", Authorization: "Bearer 789"], "host" => "https://api.epsonconnect.com", "path" => "/api/1/printing/printers/456/jobs"}
  """
  def build_create_job( payload, %{ "subject_id" => printer_id, "access_token" => access_token } ) do
    %{
      "host"   => EpsonConnect.host(),
      "path"   => Path.join( [ EpsonConnect.root(), target(), "/#{ printer_id }/jobs" ] ),
      "body"   => payload |> Jason.encode!,
      "header" => header_json() |> Keyword.merge( header_oauth2( access_token ) ),
    }
  end

  @doc """
  Build data for EpsonConnect upload file API

  ## Examples
    iex> EpsonConnect.Print.build_upload(%{"upload_uri"=>"https://dummy.upload_uri.com/dummy_path"}, "dummy_from_filename", "dummy_to_filename")
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
    iex> EpsonConnect.Print.build_print(%{"id" => "dummy_job_id"}, %{"subject_id" => "dummy_printer_id", "access_token" => "dummy_access_token"})
    %{"body" => "", "header" => ["Content-Type": "application/json; charset=utf-8", Authorization: "Bearer dummy_access_token"], "host" => "https://api.epsonconnect.com", "path" => "/api/1/printing/printers/dummy_printer_id/jobs/dummy_job_id/print"}
  """
  def build_print( %{ "id" => job_id }, %{ "subject_id" => printer_id, "access_token" => access_token } ) do
    %{
      "host"   => EpsonConnect.host(),
      "path"   => Path.join( [ EpsonConnect.root(), target(), "/#{ printer_id }/jobs/#{ job_id }/print" ] ),
      "body"   => "",
      "header" => Keyword.merge( header_json(), header_oauth2( access_token ) ),
    }
  end

  @doc """
  Build data for get job result API

  ## Examples
    iex> EpsonConnect.Print.build_get_result(%{"id" => "dummy_job_id"}, %{"subject_id" => "dummy_printer_id", "access_token" => "dummy_access_token"})
    %{"body" => "", "header" => [Authorization: "Bearer dummy_access_token"], "host" => "https://api.epsonconnect.com", "path" => "/api/1/printing/printers/dummy_printer_id/jobs/dummy_job_id"}
  """
  def build_get_result( %{ "id" => job_id }, %{ "subject_id" => printer_id, "access_token" => access_token } ) do
    %{
      "host"   => EpsonConnect.host(),
      "path"   => Path.join( [ EpsonConnect.root(), target(), "/#{ printer_id }/jobs/#{ job_id }" ] ),
      "body"   => "",
      "header" => header_oauth2( access_token ),
    }
  end

  defp header_json, do: [ "Content-Type": "application/json; charset=utf-8" ]
  defp header_oauth2( access_token ), do: [ "Authorization": "Bearer #{ access_token }" ]
end
