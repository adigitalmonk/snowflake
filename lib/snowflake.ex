defmodule Snowflake do
  @moduledoc false

  def get, do: Snowflake.Server.get()
end
