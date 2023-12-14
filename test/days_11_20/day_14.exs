defmodule Day14Test do
  use ExUnit.Case

  alias Day14, as: Subject

  @test_data """
  O....#....
  O.OO#....#
  .....##...
  OO.#O....O
  .O.....O#.
  O.#..O.#.#
  ..O..#O..O
  .......O..
  #....###..
  #OO..#....
  """

  test "execute_part_1/1" do
    result = Subject.execute_part_1(@test_data)

    assert result == 136
  end

  # test "execute_part_2/1" do
  #   result = Subject.execute_part_2(@test_data)

  #   assert result == 0
  # end
end
