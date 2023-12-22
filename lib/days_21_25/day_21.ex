defmodule Day21 do
  def execute_part_1() do
    execute_part_1(fetch_data(), 64)
  end

  def execute_part_1(data, steps) do
    data
    |> parse_input()
    |> then(fn {map, start} ->
      {searched_map, _steps} = bfs([start], map, steps)
      searched_map
    end)
    |> print()
    |> Enum.filter(fn {_, cell} -> cell.visited and cell.type in [:start, :garden] end)
    |> length()
  end

  # for part 2 -> printing extended map shows that the input will create infinite diamonds pattern
  # and executing the algorithm will slowly fill the diamonds 1 by 1
  # by working with different map multiplications and steps - determine what is the needed steps
  # to fill in 1st diamond then 2nd row of diamonds -> this will be the cycle and it's offset
  # diamonds will repeat in a pattern, making it easy to calculate covered area by repeating pattern fill
  # 0  1  0  1  0
  #   111   111
  # 0  1  0  1  0
  # 00   0S0   00
  # 0  1  0  1  0
  #   111   111
  # 0  1  0  1  0
  # repeating this pattern
  def execute_part_2(total_steps) do
    execute_part_2(fetch_data(), total_steps)
  end

  def execute_part_2(data, total_steps) do
    data
    |> parse_input()
    |> then(fn {map, start} ->
      # offset is number of steps needed to reach original map edges
      {_, pattern_offset} = bfs([start], map, 0, true)
      # cycle is number of steps needed to reach extended map edges
      {map, pattern_cycle_with_offset} = bfs([start], extend(map, 1), 0, true)
      print(map)
      pattern_cycle = pattern_cycle_with_offset - pattern_offset

      finished_cycles = ((total_steps - pattern_offset) / pattern_cycle)
      remaining_steps = rem((total_steps - pattern_offset), pattern_cycle)

      {pattern_offset, pattern_cycle}
    end)
  end

  def bfs(current_coordinates, current_map, steps, stop_at_edge? \\ false)

  def bfs(_current_coordinates, map, steps, false) when steps <= 0 do
    {map, 0}
  end

  def bfs([], map, steps, _) do
    {map, steps}
  end

  def bfs(current_coordinates, current_map, steps, stop_at_edge?) do
    # get map edges
    {x0, y0} = current_map |> Map.keys() |> Enum.min_by(&(elem(&1, 0) + elem(&1, 1)))
    # edges reached if any of current coordinates is on the edge itself
    reached_ends? = Enum.any?(current_coordinates, fn {x, y} -> x == x0 or y == y0 end)

    if reached_ends? and stop_at_edge? do
      {current_map, -steps}
    else
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
      # uncomment for visualization
      # |> visualize()

      # lower steps by 2 since we are taking 2 steps at once
      bfs(new_coordinates, map, steps - 2, stop_at_edge?)
    end
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
      visited: false
    }

  def parse_cell("#", coordinates),
    do: %{
      type: :rock,
      coordinates: coordinates,
      visited: false
    }

  def extend(map, times) do
    {x_max, y_max} = map |> Map.keys() |> Enum.max_by(&(elem(&1, 0) + elem(&1, 1)))

    Enum.flat_map(map, fn {{xn, yn}, cell} ->
      Enum.flat_map(-times..times, fn y ->
        Enum.map(-times..times, fn x ->
          # if (x == 0 and y == 0) do
          #   {coordinates, cell}
          # else
          xn = xn + x * x_max
          yn = yn + y * y_max

          {{xn, yn}, Map.put(cell, :coordinates, {xn, yn})}
          # end
        end)
      end)
    end)
    |> Map.new()
  end

  def visualize(map) do
    :timer.sleep(100)
    IO.puts("\e[H\e[2J")
    print(map)
  end

  def print(map) do
    {x1, y1} = map |> Map.keys() |> Enum.max_by(&(elem(&1, 0) + elem(&1, 1)))
    {x0, y0} = map |> Map.keys() |> Enum.min_by(&(elem(&1, 0) + elem(&1, 1)))
    IO.inspect({y0..y1, x0..x1})

    Enum.map(y0..y1, fn y ->
      Enum.map(x0..x1, fn x ->
        case Map.get(map, {x, y}) do
          %{type: :start} -> IO.ANSI.red() <> "S" <> IO.ANSI.reset()
          %{type: :rock} -> "#"
          # %{visited: true, visited_at: v} -> round(v/2)
          %{visited: true} -> IO.ANSI.green() <> "o" <> IO.ANSI.reset()
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
