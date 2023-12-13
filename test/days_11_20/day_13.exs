defmodule Day13Test do
  use ExUnit.Case

  alias Day13, as: Subject

  @test_data """
  #.##..##.
  ..#.##.#.
  ##......#
  ##......#
  ..#.##.#.
  ..##..##.
  #.#.##.#.

  #...##..#
  #....#..#
  ..##..###
  #####.##.
  #####.##.
  ..##..###
  #....#..#
  """

  describe "execute_part_1/1" do
    test "test input" do
      result = Subject.execute_part_1(@test_data)

      assert result == 405
    end

    test "cutting the input last lines will result in the same result" do
      result1 =
        Subject.execute_part_1("""
        #.##..##.
        ..#.##.#.
        ##......#
        ##......#
        ..#.##.#.
        ..##..##.
        #.#.##.#.
        """)

      result2 =
        Subject.execute_part_1("""
        #...##..#
        #....#..#
        ..##..###
        #####.##.
        #####.##.
        ..##..###
        #....#..#
        """)

      assert result1 == 5
      assert result2 == 400
    end
  end

  test "execute_par2_2/1" do
    result = Subject.execute_part_2(@test_data)

    assert result == 400
  end
end
