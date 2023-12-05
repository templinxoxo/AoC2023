defmodule Day5Test do
  use ExUnit.Case

  alias Day5, as: Subject

  @test_data """
  seeds: 79 14 55 13

  seed-to-soil map:
  50 98 2
  52 50 48

  soil-to-fertilizer map:
  0 15 37
  37 52 2
  39 0 15

  fertilizer-to-water map:
  49 53 8
  0 11 42
  42 0 7
  57 7 4

  water-to-light map:
  88 18 7
  18 25 70

  light-to-temperature map:
  45 77 23
  81 45 19
  68 64 13

  temperature-to-humidity map:
  0 69 1
  1 0 69

  humidity-to-location map:
  60 56 37
  56 93 4
  """

  test "execute_part_1/1" do
    result = Subject.execute_part_1(@test_data)

    assert result == 35
  end

  test "execute_part_1/1 - solve with ranges" do
    result = Subject.execute_part_1_ranges(@test_data)

    assert result == 35
  end

  test "execute_part_2/1" do
    result = Subject.execute_part_2(@test_data)

    assert result == 46
  end
end
