defmodule Day2Test do
  use ExUnit.Case

  alias Day2, as: Subject

  @test_data """
  Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
  Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
  Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
  Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
  Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
  """

  test "execute_part_1/1" do
    result = Subject.execute_part_1(@test_data)

    assert result == 8
  end

  test "execute_part_2/1" do
    result = Subject.execute_part_2(@test_data)

    assert result == 2286
  end
end
