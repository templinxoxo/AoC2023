defmodule Day17 do
  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> dijkstra([{0, 0, 0, :unvisited}])
    |> print_path()
    |> elem(1)
  end

  def dijkstra(nodes_map, [{_x, _y, value, :end} | _remaining_nodes]) do
    {nodes_map, value}
  end

  def dijkstra(nodes_map, [{x, y, value, _status} | remaining_nodes]) do
    {current_step_value, prev_nodes, current_path_length, status} = Map.get(nodes_map, {x, y})

    # get all neighbors excluding prev_nodes
    ([{x - 1, y}, {x, y - 1}, {x + 1, y}, {x, y + 1}] -- prev_nodes)
    |> Enum.map(fn coordinates ->
      {coordinates, Map.get(nodes_map, coordinates)}
    end)
    # remove out of bounds
    |> Enum.reject(&(&1 |> elem(1) |> is_nil()))
    # filter only unvisited
    |> Enum.reject(fn {_, {_, _, _, status}} -> status == :visited end)
    # filter only ones with path shorter than current known path
    |> Enum.filter(fn {coordinates, {value, prev_nodes, path_length, _status}} ->
      value + current_path_length < path_length
    end)
    |> Enum.map(fn {coordinates, {value, _prev_nodes, _, status}} ->
      # replace current path and path value on new nodes
      {coordinates,
       {value, ([{x, y}] ++ prev_nodes), current_path_length + value, status}}
    end)
    # reject paths going more than 4 in the same direction
    |> Enum.reject(fn {{x0, y0}, {_, history, _path_length, _status}} ->
      history = Enum.take(history, 4)
      is_strait_vertical? = Enum.all?(history, fn {_, y} -> y == y0 end)
      is_strait_horizontal? = Enum.all?(history, fn {x, _} -> x == x0 end)

      length(history) == 4 and (is_strait_vertical? or is_strait_horizontal?)
    end)
    |> then(fn next_steps ->
      # get new steps for next iteration
      new_nodes =
        next_steps
        |> Enum.map(fn {{x, y}, {_, _, path, status}} ->
          {x, y, path, status}
        end)
        # concat with other ones, sort and dedup by path length
        |> Enum.concat(remaining_nodes)
        |> Enum.sort_by(fn {_, _, path, _} -> path end)
        |> Enum.uniq_by(fn {x, y, _path, _} -> {x, y} end)

      new_entrees =
        next_steps
        |> Map.new()
        |> Map.put({x, y}, {current_step_value, prev_nodes, current_path_length, :visited})

      # merge new entrees into nodes_map
      nodes_map
      |> Map.merge(new_entrees)
      |> dijkstra(new_nodes)
    end)
  end

  def execute_part_2(data \\ fetch_data()) do
    data
    |> parse_input()

    0
  end

  # helpers
  def fetch_data() do
    Api.get_input(17)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {value, x} ->
        # key - coordinates,
        # value - cell_value, prev_nodes, current path_length, visited status
        {{x, y}, {String.to_integer(value), nil, :infinity, :unvisited}}
      end)
    end)
    |> then(fn entrees ->
      {coordinates, {last_value, _, _, _}} = List.last(entrees)
      {first_value, _, _, _} = List.first(entrees) |> elem(1)

      entrees
      |> List.replace_at(-1, {coordinates, {last_value, nil, nil, :end}})
      |> List.replace_at(0, {{0, 0}, {first_value, [], 0, :unvisited}})
      |> Map.new()
    end)
  end

  def print_path({nodes_map, len}) do
    {{x, y}, {_, history, _, _}} =
      nodes_map
      |> Enum.find(fn {_, {_, _, _, status}} -> status == :end end)

    0..y
    |> Enum.map(fn y ->
      0..x
      |> Enum.map(fn x ->
        if {x, y} in history do
          "#"
        else
          "."
        end
      end)
      |> Enum.join()
      |> IO.puts()
    end)

    {nodes_map, len}
  end
end
