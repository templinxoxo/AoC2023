defmodule Day6Test do
  use ExUnit.Case

  alias Day6, as: Subject

  @test_data """
  Time:      7  15   30
  Distance:  9  40  200
  """

  test "execute_part_1/1" do
    result = Subject.execute_part_1(@test_data)

    assert result == 288
  end

  test "execute_part_2/1" do
    result = Subject.execute_part_2(@test_data)

    assert result == 71503
  end
end
