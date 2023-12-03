defmodule Day3Test do
  use ExUnit.Case

  alias Day3, as: Subject

  @test_data """
  467..114..
  ...*......
  ..35..633.
  ......#...
  617*......
  .....+.58.
  ..592.....
  ......755.
  ...$.*....
  .664.598..
  """

  test "execute_part_1/1" do
    result = Subject.execute_part_1(@test_data)

    assert result == 4361
  end

  test "execute_part_2/1" do
    result = Subject.execute_part_2(@test_data)

    assert result == 467_835
  end
end
