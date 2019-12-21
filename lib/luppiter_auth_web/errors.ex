defmodule LuppiterAuthWeb.Errors do
  defmodule UnauthorizedError do
    defexception plug_status: 401, message: "unauthorized"
  end
end

defimpl Plug.Exception, for: LuppiterAuthWeb.Errors.UnauthorizedError do
  def status(_), do: 401
end
