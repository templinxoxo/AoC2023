defmodule Day11Test do
  use ExUnit.Case

  alias Day11, as: Subject

  @test_data """
  ...#......
  .......#..
  #.........
  ..........
  ......#...
  .#........
  .........#
  ..........
  .......#..
  #...#.....
  """

  test "execute_part_1/1" do
    result = Subject.execute_part_1(@test_data)

    assert result == 374
  end

  test "execute_part_2/2 - 10 expansions" do
    result = Subject.execute_part_2(@test_data, 10)

    assert result == 1030
  end

  test "execute_part_2/2 - 100 expansions" do
    result = Subject.execute_part_2(@test_data, 100)

    assert result == 8410
  end
end
