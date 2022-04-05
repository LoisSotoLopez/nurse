defmodule Nurse.Nurselog do
  require Logger

  def init() do
    :logger.add_handlers(:nurse)
  end

  def info(format) do
    info(format, [])
  end

  def info(format, args) do
    :logger.info(format, args)
  end

  def info_w(format) do
    info_w(format, [])
  end

  def info_w(format, args) do
    :logger.info(format, args, %{domain: [:workers]})
  end
end
