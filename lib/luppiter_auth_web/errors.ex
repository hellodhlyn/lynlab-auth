defmodule LuppiterAuthWeb.Errors do
  defmodule InvalidProviderIdError do
    defexception plug_status: 400, message: "invalid_provider_id"
  end

  defmodule UnauthorizedError do
    defexception plug_status: 401, message: "unauthorized"
  end

  defmodule UnauthorizedApplicationError do
    defexception plug_status: 401, message: "unauthorized_application"
  end
end

defimpl Plug.Exception, for: [
  LuppiterAuthWeb.Errors.InvalidProviderIdError,
] do
  def status(_), do: 400
end


defimpl Plug.Exception, for: [
  LuppiterAuthWeb.Errors.UnauthorizedError,
  LuppiterAuthWeb.Errors.UnauthorizedApplicationError,
] do
  def status(_), do: 401
end
