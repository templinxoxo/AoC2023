defmodule Day9Test do
  use ExUnit.Case

  alias Day9, as: Subject

  @test_data """
  0 3 6 9 12 15
  1 3 6 10 15 21
  10 13 16 21 30 45
  """

  test "execute_part_1/1" do
    result = Subject.execute_part_1(@test_data)

    assert result == 114
  end

  test "execute_part_2/1" do
    result = Subject.execute_part_2(@test_data)

    assert result == 2
  end
end
