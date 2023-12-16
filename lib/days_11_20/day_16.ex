defmodule Day16 do
  # execute methods

  def execute_part_1(data \\ fetch_data()) do
    Timer.time("pt1", fn ->
      data
      |> parse_input()
      |> get_visited_elements()
      |> calculate_covered_area()
    end)
  end

  def brute_force_part_2(data \\ fetch_data()) do
    Timer.time("pt2", fn ->
      data
      |> parse_input()
      |> then(fn map ->
        map
        |> get_starting_positions()
        |> Enum.map(fn {x, y, direction} = starting_position ->
          label = "{#{x}, #{y}} #{direction}"

          Timer.time(label, fn ->
            get_visited_elements([starting_position], [], map)
            |> calculate_covered_area()
          end)
        end)
        |> Enum.max()
      end)
    end)
  end

  def get_starting_positions(map) do
    x_max = (map |> List.first() |> length()) - 1
    y_max = (map |> length()) - 1

    vertical =
      0..x_max
      |> Enum.flat_map(fn x ->
        [{x, 0, "v"}, {y_max, x, "^"}]
      end)

    horizontal =
      0..y_max
      |> Enum.flat_map(fn y ->
        [{0, y, ">"}, {x_max, y, "<"}]
      end)

    vertical ++ horizontal
  end

  def get_visited_elements(map) do
    get_visited_elements([{0, 0, ">"}], [], map)
  end

  def get_visited_elements([], visited, _map) do
    # print(visited, map)

    visited
  end

  def get_visited_elements(current_positions, visited, map) do
    current_positions
    |> Enum.flat_map(&get_next_steps(&1, map))
    |> remove_finished_paths(visited, map)
    |> get_visited_elements(visited ++ current_positions, map)
  end

  def remove_finished_paths(positions, visited, map) do
    positions
    |> Enum.filter(fn {x, y, _direction} = position ->
      cond do
        position in visited ->
          # remove positions that loop into already visited paths
          false

        y >= length(map) or y < 0 or x >= length(List.first(map)) or x < 0 ->
          # remove positions that go out of bounds
          false

        true ->
          true
      end
    end)
  end

  def get_next_steps({x, y, direction}, map) do
    current_element = map |> Enum.at(y) |> Enum.at(x)

    case {direction, current_element} do
      {">", "."} -> [{x + 1, y, ">"}]
      {">", "-"} -> [{x + 1, y, ">"}]
      {">", "\\"} -> [{x, y + 1, "v"}]
      {">", "/"} -> [{x, y - 1, "^"}]
      {">", "|"} -> [{x, y - 1, "^"}, {x, y + 1, "v"}]
      #
      {"<", "."} -> [{x - 1, y, "<"}]
      {"<", "-"} -> [{x - 1, y, "<"}]
      {"<", "/"} -> [{x, y + 1, "v"}]
      {"<", "\\"} -> [{x, y - 1, "^"}]
      {"<", "|"} -> [{x, y - 1, "^"}, {x, y + 1, "v"}]
      #
      {"^", "."} -> [{x, y - 1, "^"}]
      {"^", "\\"} -> [{x - 1, y, "<"}]
      {"^", "/"} -> [{x + 1, y, ">"}]
      {"^", "-"} -> [{x - 1, y, "<"}, {x + 1, y, ">"}]
      {"^", "|"} -> [{x, y - 1, "^"}]
      #
      {"v", "."} -> [{x, y + 1, "v"}]
      {"v", "|"} -> [{x, y + 1, "v"}]
      {"v", "/"} -> [{x - 1, y, "<"}]
      {"v", "\\"} -> [{x + 1, y, ">"}]
      {"v", "-"} -> [{x - 1, y, "<"}, {x + 1, y, ">"}]
    end
  end

  def calculate_covered_area(visited) do
    visited
    |> Enum.map(fn {x, y, _} -> {x, y} end)
    |> Enum.uniq()
    |> length()
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))

    # |> then(fn data ->
    #   print([], data)
    #   data
    # end)
  end

  def print(visited, map) do
    visited_map =
      visited
      |> Enum.map(fn
        {x, y, direction} -> {{x, y}, direction}
      end)
      |> Map.new()

    map
    |> Enum.with_index()
    |> Enum.each(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn
        {".", x} -> Map.get(visited_map, {x, y}, ".")
        {elem, _x} -> elem
      end)
      |> Enum.join()
      |> IO.puts()
    end)
  end

  def fetch_data do
    # this time data has to be imported from separate file
    # "/" in string are removed by default and needs to be manually replaced with "//"
    # for the data to work
    Day16.Input.data()
  end
end
