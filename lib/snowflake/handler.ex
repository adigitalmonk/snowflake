defmodule Snowflake.Handler do
  @moduledoc false
  use Echo.Handler

  def on_connect(socket), do: {:noreply, socket}
  def on_exit(socket), do: {:noreply, socket}

  def serialize(message), do: (message |> Integer.to_string()) <> "\n"
  def deserialize(message), do: message |> String.trim() |> String.downcase()

  def handle_message("get", socket) do
    {:reply, Snowflake.Server.get(), socket}
  end

  def handle_message(_message, socket) do
    {:noreply, socket}
  end
end
