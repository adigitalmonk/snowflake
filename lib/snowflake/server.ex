defmodule Snowflake.Server do
  @moduledoc false

  use GenServer
  require Logger

  defstruct [:node_id, :sequence_id]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end

  def init(opts) do
    node_id = Keyword.get(opts, :node_id, 1)
    {:ok, %__MODULE__{node_id: node_id, sequence_id: 0}}
  end

  def handle_call(:get, _from, %{node_id: id, sequence_id: idx} = state) do
    timestamp = System.os_time(:millisecond)
    snowflake = build_snowflake(timestamp, id, idx)
    Logger.debug("Generated: #{Integer.to_string(snowflake, 2)}")
    {:reply, snowflake, state, {:continue, :increment}}
  end

  def handle_continue(:increment, %{sequence_id: idx} = state) do
    {:noreply, %{state | sequence_id: rem(idx + 1, 4096)}}
  end

  def build_snowflake(timestamp, node_id, sequence_id) do
    import Bitwise
    timestamp = timestamp <<< 22
    node_id = node_id <<< 12
    timestamp ||| node_id ||| sequence_id
  end

  if Mix.env() == :dev do
    defmodule Bench do
      @moduledoc false
      alias Snowflake.Server
      require Logger

      def run(iterations \\ 100_000) do
        previous = Logger.level()
        Logger.configure(level: :info)

        {exec_ms, _} =
          :timer.tc(
            fn ->
              Enum.each(0..iterations, fn _ ->
                Server.get()
              end)
            end,
            :millisecond
          )

        Logger.configure(level: previous)
        Logger.debug("Generated #{iterations} Snowflakes in ~#{exec_ms}ms")
      end
    end
  end
end
