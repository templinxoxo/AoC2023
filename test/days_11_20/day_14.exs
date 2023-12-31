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

  describe "execute_part_2/1" do
    test "1000000000 cycles" do
      result =
        Subject.execute_part_2(@test_data, 1_000_000_000)
        |> IO.inspect()

      assert result == 64
    end
  end
end
