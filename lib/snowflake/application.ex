defmodule Snowflake.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    node_id = Application.get_env(:snowflake, :node_id)
    port = Application.get_env(:snowflake, :port)
    pool_size = Application.get_env(:snowflake, :pool_size)

    children = [
      {Snowflake.Server, [node_id: node_id]},
      {Snowflake.Echo, port: port, pool_size: pool_size}
    ]

    opts = [strategy: :one_for_one, name: Snowflake.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
