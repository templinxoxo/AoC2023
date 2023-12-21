defmodule Day21 do
  def execute_part_1() do
    execute_part_1(fetch_data(), 64)
  end

  def execute_part_1(data, steps) do
    data
    |> parse_input()
    |> then(fn {map, start} ->
      bfs([start], map, steps)
    end)
    |> length()
  end

  def bfs(current_coordinates, _map, 0) do
    current_coordinates
  end

  def bfs(current_coordinates, map, steps) do
    current_coordinates
    # for each coordinate, get it's neighbors
    |> Enum.flat_map(&get_neighbors/1)
    # remove rocks
    |> Enum.reject(&(Map.get(map, &1) == :rock))
    # deduplicate
    |> Enum.uniq()
    |> bfs(map, steps - 1)
  end

  def get_neighbors({x, y}), do: [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]

  # helpers
  def fetch_data() do
    Api.get_input(21)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn
        {".", x} -> {{x, y}, :garden}
        {"S", x} -> {{x, y}, :start}
        {"#", x} -> {{x, y}, :rock}
      end)
    end)
    |> then(fn map ->
      start = map |> Enum.find(&(elem(&1, 1) == :start)) |> elem(0)

      {Map.new(map), start}
    end)
  end
end
