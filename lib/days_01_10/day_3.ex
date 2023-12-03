defmodule Day3 do
  # execute methods
  def execute_part_1(data \\ fetch_data()) do
    {gears, numbers} = parse_input(data)

    gears
    |> Enum.flat_map(fn {_, [coordinate]} ->
      get_adjacent_coordinates(coordinate)
    end)
    |> get_numbers_in_coordinates(numbers)
    |> Enum.sum()
  end

  def execute_part_2(data \\ fetch_data()) do
    {gears, numbers} = parse_input(data)

    gears
    |> Enum.filter(fn {gear, _} -> gear == "*" end)
    |> Enum.map(fn {_, [coordinate]} ->
      coordinate
      |> get_adjacent_coordinates()
      |> get_numbers_in_coordinates(numbers)
      |> case do
        [num1, num2] -> num1 * num2
        _ -> 0
      end
    end)
    |> Enum.sum()
  end

  def get_adjacent_coordinates({x, y}) do
    (x - 1)..(x + 1)
    |> Enum.flat_map(fn x ->
      (y - 1)..(y + 1)
      |> Enum.map(fn y ->
        {x, y}
      end)
    end)
  end

  def get_numbers_in_coordinates(coordinates, numbers) do
    numbers
    |> Enum.filter(fn {_, points} -> Enum.any?(points, &(&1 in coordinates)) end)
    |> Enum.map(fn {number, _} -> String.to_integer(number) end)
  end

  # helpers
  def fetch_data() do
    Api.get_input("day")
  end

  @gears_regex ~r/([^\.|\d|\n)])/
  @numbers_regex ~r/\d+/

  def parse_input(input) do
    {
      scan_input(input, @gears_regex),
      scan_input(input, @numbers_regex)
    }
  end

  def scan_input(input, regex) do
    line_len = input |> String.split("\n") |> List.first() |> String.length()
    input = String.replace(input, "\n", "")

    values = Regex.scan(regex, input) |> Enum.map(&List.first(&1))

    indexes =
      Regex.scan(regex, input, return: :index)
      |> Enum.map(fn [{start, length} | _] ->
        y_index = floor(start / line_len)
        x_index = rem(start, line_len)

        x_index..(x_index + length - 1)
        |> Enum.map(&{y_index, &1})
      end)

    Enum.zip(values, indexes)
  end
end
