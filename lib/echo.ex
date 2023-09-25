defmodule Snowflake.Echo do
  @moduledoc false

  use Echo,
    handler: Snowflake.Handler
end
