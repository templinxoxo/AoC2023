defmodule Day1Test do
  use ExUnit.Case

  alias Day1, as: Subject

  @test_data_1 """
  1abc2
  pqr3stu8vwx
  a1b2c3d4e5f
  treb7uchet
  """

  @test_data_2 """
  two1nine
  eightwothree
  abcone2threexyz
  xtwone3four
  4nineeightseven2
  zoneight234
  7pqrstsixteen
  """

  test "execute_part_1/1" do
    result = Subject.execute_part_1(@test_data_1)

    assert result == 142
  end

  test "execute_part_2/1" do
    result = Subject.execute_part_2(@test_data_2)

    assert result == 281
  end

  test "find_line_digits/1 handles overlapping words" do
    result = Subject.find_line_digits("oneight")

    assert result == [1, 8]
  end
end
