import Config

snowflake_node_id =
  System.get_env("SNOWFLAKE_NODE_ID", "1")
  |> String.to_integer()

snowflake_port_id =
  System.get_env("SNOWFLAKE_PORT_ID", "3000")
  |> String.to_integer()

snowflake_poool_size =
  System.get_env("SNOWFLAKE_POOL_SIZE", "1")
  |> String.to_integer()

config :snowflake,
  node_id: snowflake_node_id,
  port: snowflake_port_id,
  pool_size: snowflake_poool_size

log_level =
  System.get_env("SNOWFLAKE_LOG_LEVEL", "warning")
  |> case do
    "emergency" -> :emergency
    "alert" -> :alert
    "critical" -> :critical
    "error" -> :error
    "warning" -> :warning
    "notice" -> :notice
    "info" -> :info
    _ -> :debug
  end

config :logger, level: log_level
