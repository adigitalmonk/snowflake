defmodule SnowflakeTest do
  use ExUnit.Case

  describe "get/0" do
    test "it generates unique identifiers" do
      generated_ids = Enum.map(0..100, fn _ -> Snowflake.Server.get() end)
      unique_ids = Enum.uniq(generated_ids)
      assert Enum.count(generated_ids) == Enum.count(unique_ids)
    end
  end
end
