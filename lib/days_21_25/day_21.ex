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
    |> print()
    |> Enum.filter(fn {_, cell} -> cell.visited and cell.type in [:start, :garden] end)
    |> length()
  end

  def bfs(_current_coordinates, map, steps) when steps <= 0 do
    map
  end

  def bfs([], map, _steps) do
    map
  end

  def bfs(current_coordinates, current_map, steps) do
    new_coordinates =
      current_coordinates
      # for each coordinate, get it's neighbors neighbors. This simulates taking 2 steps at once instead of 1
      # we can mark each 2-step coordinate as visited - algorithm can loop for all remaining (even) steps and end there
      |> Enum.flat_map(fn coordinates ->
        coordinates
        |> get_neighbors()
        # reject neighbors that are rocks - cannot go through those
        |> Enum.map(&get_cell(&1, current_map))
        |> reject_unavailable()
        |> Enum.flat_map(fn neighbor -> get_neighbors(neighbor.coordinates) end)
      end)
      |> Enum.map(&get_cell(&1, current_map))
      # remove rocks (again)
      |> reject_unavailable
      # remove already visited
      |> Enum.reject(& &1.visited)
      # dedup
      |> Enum.map(& &1.coordinates)
      |> Enum.uniq()

    # for each of new points - update value a cell in map to visited
    map =
      Enum.reduce(new_coordinates, current_map, fn coordinates, map ->
        Map.update!(map, coordinates, &Map.merge(&1, %{visited: true, visited_at: steps - 2}))
      end)

    # lower steps by 2 since we are taking 2 steps at once
    bfs(new_coordinates, map, steps - 2)
  end

  def get_cell(coordinates, map) do
    Map.get(map, coordinates)
  end

  def reject_unavailable(list) do
    Enum.reject(list, &(is_nil(&1) or &1.type == :rock))
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
      |> Enum.map(fn {cell, x} ->
        {{x, y}, parse_cell(cell, {x, y})}
      end)
    end)
    |> then(fn map ->
      start =
        map
        |> Enum.find(fn {_, cell} -> cell.type == :start end)
        |> elem(1)
        |> Map.get(:coordinates)

      {Map.new(map), start}
    end)
  end

  def parse_cell(".", coordinates),
    do: %{
      type: :garden,
      coordinates: coordinates,
      visited: false
    }

  def parse_cell("S", coordinates),
    do: %{
      type: :start,
      coordinates: coordinates,
      visited: true
    }

  def parse_cell("#", coordinates),
    do: %{
      type: :rock,
      coordinates: coordinates,
      visited: false
    }

  def print(map) do
    {x, y} = map |> Map.keys() |> Enum.max_by(&(elem(&1, 0) + elem(&1, 1)))

    Enum.map(0..y, fn y ->
      Enum.map(0..x, fn x ->
        case Map.get(map, {x, y}) do
          %{type: :start} -> "S"
          %{type: :rock} -> "#"
          %{visited: true, visited_at: v} -> round(v/2)
          %{visited: true} -> "o"
          _ -> "."
        end
      end)
      |> Enum.join()
      |> IO.puts()
    end)

    IO.puts("")
    map
  end
end
