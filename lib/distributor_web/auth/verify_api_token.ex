defmodule DistributorWeb.VerifyApiToken do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    api_token = System.get_env("DISTRIBUTOR_API_TOKEN")
    authorization_header = conn |> get_req_header("Authorization")

    # Do not check for api token in non-prod environment
    if System.get_env("DISTRIBUTOR_ENV") != "production" || api_token == authorization_header do
      conn
    else
      {:ok, body} = Phoenix.json_library().encode(%{reason: type, message: "Unauthorized."})

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(401, body)
    end
  end
end
