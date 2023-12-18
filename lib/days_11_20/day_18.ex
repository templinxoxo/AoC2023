defmodule Day18 do
  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    # change initial instruction into set of border ranges
    |> get_borders()
    # go by rows and count inside points between borders
    |> count_inside_points()
  end

  def execute_part_2(data \\ fetch_data()) do
    data
    |> parse_input()
    |> Enum.map(&convert_to_decimal/1)
    # call same methods as pt1 with changed input
    |> get_borders()
    |> count_inside_points()
  end

  def count_inside_points(borders) do
    # go through all rows (y coordinates)
    borders
    |> get_map_row_ranges()
    # and count points between vertical borders
    |> Enum.map(fn {row, repetitions} ->
      get_point_ranges_between_vertical_borders(borders, row)
      |> Enum.concat(get_point_ranges_on_horizontal_borders(borders, row))
      |> concat_ranges()
      |> Enum.map(&Range.size/1)
      |> Enum.sum()
      |> then(fn points -> points * repetitions end)
    end)
    |> Enum.sum()
  end

  def get_map_row_ranges(borders) do
    borders
    # from all horizontal borders
    |> Enum.filter(fn {align, _, _, _} -> align == :horizontal end)
    # get uniq row indexes
    |> Enum.map(fn {_, _, _, y} -> y end)
    |> Enum.uniq()
    |> then(fn rows ->
      # then based on row indexes, create ranges of rows in between them
      max_range = rows |> Enum.min_max() |> then(&(elem(&1, 0)..elem(&1, 1)))

      Enum.reduce(rows, [max_range], fn row, ranges ->
        Enum.map(ranges, fn
          # if row is 1-element range, remove it
          a..a when a == row -> nil
          # if row is start or end of a range, shorten it
          a..b when a == row -> (a + 1)..b
          a..b when b == row -> a..(b - 1)
          # if row inside range, - split it into 2 ranges
          a..b when a < row and row < b -> [a..(row - 1), (row + 1)..b]
          # else - keep range as is
          range -> range
        end)
        |> Enum.reject(&is_nil(&1))
        |> List.flatten()
      end)
      # concat with borders
      |> Enum.concat(rows)
      # return as row for calculation and multiplier for range
      |> Enum.map(fn
        row.._ = range -> {row, Range.size(range)}
        row -> {row, 1}
      end)
    end)
  end

  def concat_ranges(ranges) do
    ranges
    |> Enum.sort_by(& &1.first, :desc)
    |> Enum.reduce([], fn
      range, [] ->
        [range]

      range1, [range2 | rest] ->
        if Range.disjoint?(range1, range2) do
          [range1, range2 | rest]
        else
          # if ranges are conjoint, concat both into 1 range
          [min(range1.first, range2.first)..max(range1.last, range2.last) | rest]
        end
    end)
  end

  def get_point_ranges_on_horizontal_borders(borders, row) do
    borders
    # get vertical borders in current row
    |> Enum.filter(fn {align, _, _, y} -> align == :horizontal and y == row end)
    |> Enum.map(fn {_, _, col_range, _} -> col_range end)
  end

  def get_point_ranges_between_vertical_borders(borders, row) do
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
    |> Enum.map(fn [starting_border_group, ending_border_group] ->
      starting_border_group
      |> Enum.concat(ending_border_group)
      |> Enum.map(fn {_, _, x, _} -> x end)
      |> Enum.min_max()
      |> then(fn {starting_border, ending_border} ->
        starting_border..ending_border
      end)
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

  def convert_to_decimal({_direction, _step, hex}) do
    [direction | digits] =
      hex
      |> String.replace(["#", "(", ")"], "")
      |> String.split("", trim: true)
      |> Enum.reverse()

    decimal =
      digits
      |> Enum.map(&to_int/1)
      |> Enum.with_index()
      |> Enum.map(fn {digit, power} -> digit * 16 ** power end)
      |> Enum.sum()

    direction = convert_direction(direction)

    {direction, decimal, nil}
  end

  def to_int("a"), do: 10
  def to_int("b"), do: 11
  def to_int("c"), do: 12
  def to_int("d"), do: 13
  def to_int("e"), do: 14
  def to_int("f"), do: 15
  def to_int(digit), do: String.to_integer(digit)

  def convert_direction("0"), do: "R"
  def convert_direction("1"), do: "D"
  def convert_direction("2"), do: "L"
  def convert_direction("3"), do: "U"
end
