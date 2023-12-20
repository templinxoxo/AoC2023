defmodule Day20Test do
  use ExUnit.Case

  alias Day20, as: Subject

  @test_data_1 """
  broadcaster -> a, b, c
  %a -> b
  %b -> c
  %c -> inv
  &inv -> a
  """

  @test_data_2 """
  broadcaster -> a
  %a -> inv, con
  &inv -> b
  %b -> con
  &con -> output
  """

  describe "execute_part_1/1" do
    test "data 1" do
      result = Subject.execute_part_1(@test_data_1)

      assert result == 32_000_000
    end

    test "data 2" do
      result = Subject.execute_part_1(@test_data_2)

      assert result == 11_687_500
    end
  end
end
