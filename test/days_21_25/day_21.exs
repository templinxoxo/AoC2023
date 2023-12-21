defmodule Day21Test do
  use ExUnit.Case

  alias Day21, as: Subject

  @test_data """
  ...........
  .....###.#.
  .###.##..#.
  ..#.#...#..
  ....#.#....
  .##..S####.
  .##..#...#.
  .......##..
  .##.#.####.
  .##..##.##.
  ...........
  """

  test "execute_part_1/2" do
    result = Subject.execute_part_1(@test_data, 6)

    assert result == 16
  end
end
