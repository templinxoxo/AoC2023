defmodule Day17Test do
  use ExUnit.Case

  alias Day17, as: Subject

  @test_data """
  2413432311323
  3215453535623
  3255245654254
  3446585845452
  4546657867536
  1438598798454
  4457876987766
  3637877979653
  4654967986887
  4564679986453
  1224686865563
  2546548887735
  4322674655533
  """

  test "execute_part_1/1" do
    result = Subject.execute_part_1(@test_data)

    assert result == 102
  end

  test "tricky path" do
    result  = """
    112999
    911111
    """
    |> Subject.execute_part_1()

    assert result == 7
  end

  # test "execute_part_2/1" do
  #   result = Subject.execute_part_2(@test_data)

  #   assert result == 0
  # end
end
