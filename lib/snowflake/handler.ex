defmodule Snowflake.Handler do
  @moduledoc false
  use Tango.Handler

  def on_connect(socket), do: {:noreply, socket}
  def on_exit(socket), do: {:noreply, socket}
  def handle_out(message), do: (message |> Integer.to_string()) <> "\n"
  def handle_in(message), do: message |> String.trim() |> String.downcase()
  def handle_message("get", socket), do: {:reply, Snowflake.Server.get(), socket}
  def handle_message(_message, socket), do: {:noreply, socket}
end
