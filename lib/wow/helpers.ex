defmodule Wow.Helpers do
  require Logger

  def with_logs(func) do
    func.()
  rescue
    exception ->
      Logger.debug(Exception.message(exception))
      Logger.debug(Exception.format_stacktrace(__STACKTRACE__))
      reraise(exception, __STACKTRACE__)
  end
end
