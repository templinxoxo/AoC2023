defmodule Day23Test do
  use ExUnit.Case

  alias Day23, as: Subject

  @test_data """
  #.#####################
  #.......#########...###
  #######.#########.#.###
  ###.....#.>.>.###.#.###
  ###v#####.#v#.###.#.###
  ###.>...#.#.#.....#...#
  ###v###.#.#.#########.#
  ###...#.#.#.......#...#
  #####.#.#.#######.#.###
  #.....#.#.#.......#...#
  #.#####.#.#.#########v#
  #.#...#...#...###...>.#
  #.#.#v#######v###.###v#
  #...#.>.#...>.>.#.###.#
  #####v#.#.###v#.#.###.#
  #.....#...#...#.#.#...#
  #.#########.###.#.#.###
  #...###...#...#...#.###
  ###.###.#.###v#####v###
  #...#...#.#.>.>.#.>.###
  #.###.###.#.###.#.#v###
  #.....###...###...#...#
  #####################.#
  """

  test "execute_part_1/1" do
    result = Subject.execute_part_1(@test_data)

    assert result == 94
  end
end
