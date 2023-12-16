defmodule Day16 do
  # execute methods

  def execute_part_1(data) do
    data
    |> parse_input()
    |> follow_light_paths()
    |> calculate_covered_area()
  end

  def follow_light_paths(paths \\ [[{0, 0, ">"}]], map) do
    paths
    |> Enum.flat_map(&go_to_next_step(&1, map))
    |> mark_finished_paths(map)
    |> then(fn paths ->
      all_paths_finished? =
        Enum.all?(paths, fn path ->
          path
          |> List.last()
          |> elem(2)
          |> then(&(&1 in [:end, :loop]))
        end)

      if all_paths_finished? do
        print(paths, map)
        paths
      else
        follow_light_paths(paths, map)
      end
    end)
  end

  def go_to_next_step(path, map) do
    path
    |> List.last()
    |> case do
      {_, _, :end} ->
        [path]

      {_, _, :loop} ->
        [path]

      elem ->
        elem
        |> get_next_steps(map)
        |> Enum.map(&(path ++ [&1]))
    end
  end

  def mark_finished_paths(paths, map) do
    paths
    |> Enum.map(fn path ->
      last_elem = List.last(path)
      {x, y, direction} = last_elem

      cond do
        direction in [:end, :loop] ->
          path

        List.flatten(paths) |> Enum.filter(&(&1 == last_elem)) |> length() > 1 ->
          # mark paths that loop into already visited paths
          path ++ [{x, y, :loop}]

        y >= length(map) or y < 0 or x >= length(List.first(map)) or x < 0 ->
          # mark paths that go out of bounds
          path |> Enum.take(length(path) - 1) |> Enum.concat([{x, y, :end}])

        true ->
          path
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
      {"v", "/"} -> [{x - 2, y, "<"}]
      {"v", "\\"} -> [{x + 1, y, ">"}]
      {"v", "-"} -> [{x - 1, y, "<"}, {x + 1, y, ">"}]
    end
  end

  def calculate_covered_area(paths) do
    paths
    |> List.flatten()
    |> Enum.reject(&(elem(&1, 2) in [:end, :loop]))
    |> Enum.map(fn {x, y, _} -> {x, y} end)
    |> Enum.uniq()
    |> length
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  def print(paths, map) do
    visited =
      paths
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.reject(&(elem(&1, 2) in [:end, :loop]))
      |> Enum.group_by(fn {x, y, _} -> {x, y} end)
      |> Enum.map(fn
        {coords, [{_, _, direction}]} -> {coords, direction}
        {coords, results} -> {coords, length(results)}
      end)
      |> Map.new()

    map
    |> Enum.with_index()
    |> Enum.each(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn
        {".", x} -> Map.get(visited, {x, y}, ".")
        {elem, _x} -> elem
      end)
      |> Enum.join()
      |> IO.puts()
    end)
  end
end
