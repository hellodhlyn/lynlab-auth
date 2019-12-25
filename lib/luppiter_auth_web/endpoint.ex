defmodule LuppiterAuthWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :luppiter_auth

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  # if code_reloading? do
  #   plug Phoenix.CodeReloader
  # end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug CORSPlug, origin: (System.get_env("ALLOWED_ORIGINGS", "http://localhost:3000") |> String.split())

  plug LuppiterAuthWeb.Router
end
