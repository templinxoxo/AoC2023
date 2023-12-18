defmodule Day18 do
  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    # change initial instruction into set of border ranges
    |> get_borders()
    # go by rows and count inside points between borders
    |> count_inside_points()
  end

  def count_inside_points(borders) do
    # go through all rows (y coordinates)
    borders
    |> Enum.filter(fn {align, _, _, _} -> align == :horizontal end)
    |> Enum.map(fn {_, _, _, y} -> y end)
    |> Enum.min_max()
    |> then(fn {y_min, y_max} -> y_min..y_max end)
    # and count points between vertical borders
    |> Enum.map(fn y ->
      borders
      |> get_points_between_vertical_borders(y)
      |> Enum.concat(get_points_on_horizontal_borders(borders, y))
      |> Enum.uniq()
      |> length()
    end)
    |> Enum.sum()
  end

  def get_points_on_horizontal_borders(borders, row) do
    borders
    # get vertical borders in current row
    |> Enum.filter(fn {align, _, _, y} -> align == :horizontal and y == row end)
    |> Enum.flat_map(fn {_, _, col_range, _} -> Enum.map(col_range, & &1) end)
  end

  def get_points_between_vertical_borders(borders, row) do
    borders
    # get vertical borders in current row
    |> Enum.filter(fn {align, _, _, row_range} -> align == :vertical and row in row_range end)
    |> Enum.sort_by(fn {_, _, x, _} -> x end)
    # group consecutive borders in the same direction together
    |> Enum.reduce([], &group_by_direction/2)
    |> Enum.reverse()
    # chunk every 2 borders -> this will always return 2 border groups in the different directions.
    # all points in between are inside the area
    #   example
    #   1  #       #
    #   2  #       #
    #   3  ###...###
    #   4    #   #
    #   in line 3 there are 4 vertical borders (on x: 0, 2, 6, 8) and total of 9 points between them (from 0 to 8 inc)
    # this algorithm will group [0, 2] and [6, 8] together and count area between based on further edges of both
    |> Enum.chunk_every(2, 2)
    # get all points of all in between borders
    |> Enum.flat_map(fn [starting_border_group, ending_border_group] ->
      starting_border_group
      |> Enum.concat(ending_border_group)
      |> Enum.map(fn {_, _, x, _} -> x end)
      |> Enum.min_max()
      |> then(fn {starting_border, ending_border} ->
        ending_border..starting_border
      end)
      |> Enum.map(& &1)
    end)
  end

  def group_by_direction(element, []), do: [[element]]

  def group_by_direction(element, acc) do
    {_align, direction1, _x, _y} = element
    [[{_align, direction2, _x, _y} | _] = current_group | rest] = acc

    if direction1 == direction2 do
      [current_group ++ [element]] ++ rest
    else
      [[element]] ++ acc
    end
  end

  def get_borders(instructions) do
    get_borders(instructions, {0, 0}, [])
  end

  def get_borders([], {0, 0}, borders) do
    borders
  end

  def get_borders([{"R", step, _} | instructions], {x0, y}, borders) do
    x = x0 + step
    borders = borders ++ [{:horizontal, "R", x0..x, y}]

    get_borders(instructions, {x, y}, borders)
  end

  def get_borders([{"L", step, _} | instructions], {x0, y}, borders) do
    x = x0 - step
    borders = borders ++ [{:horizontal, "L", x..x0, y}]

    get_borders(instructions, {x, y}, borders)
  end

  def get_borders([{"D", step, _} | instructions], {x, y0}, borders) do
    y = y0 + step
    borders = borders ++ [{:vertical, "D", x, y0..y}]

    get_borders(instructions, {x, y}, borders)
  end

  def get_borders([{"U", step, _} | instructions], {x, y0}, borders) do
    y = y0 - step
    borders = borders ++ [{:vertical, "U", x, y..y0}]

    get_borders(instructions, {x, y}, borders)
  end

  # helpers
  def fetch_data() do
    Api.get_input(18)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [direction, step, color] =
        String.split(row, " ", trim: true)

      {direction, String.to_integer(step), color}
    end)
  end
end
