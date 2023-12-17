defmodule Day17 do
  @start_positions [{0, 0, ">", 0, :unvisited}, {0, 0, "v", 0, :unvisited}]

  def execute_part_1(data \\ fetch_data()) do
    delta_range = 1..3

    Timer.time(fn ->
      data
      |> parse_input()
      |> dijkstra(@start_positions, delta_range)
    end)
  end

  def dijkstra(_nodes_map, [{_x, _y, _direction, value, :end} | _remaining_nodes], _delta_range) do
    value
  end

  def dijkstra(nodes_map, [{x, y, direction, _value, _status} | remaining_nodes], delta_range) do
    {current_step_value, prev_node, current_path_length, _status} =
      Map.get(nodes_map, {x, y, direction})

    delta_range
    |> Enum.flat_map(fn delta ->
      [{x - delta, y, "<"}, {x, y - delta, "^"}, {x + delta, y, ">"}, {x, y + delta, "v"}]
    end)
    # get all possible directions excluding going back
    |> Enum.reject(fn {_x, _y, dir} -> direction in [dir, opposite(dir)] end)
    |> Enum.map(fn {x1, y1, dir} = coordinates ->
      # todo - get all in between
      x..x1
      |> Enum.flat_map(fn xn ->
        Enum.map(y..y1, fn yn -> {xn, yn} end)
      end)
      |> Enum.reject(fn {xn, yn} -> {xn, yn} == {x, y} end)
      |> Enum.map(fn {x, y} ->
        Map.get(nodes_map, {x, y, dir})
      end)
      |> then(fn nodes ->
        if Enum.any?(nodes, &is_nil(&1)) do
          nil
        else
          value =
            Enum.reduce(nodes, 0, fn {value, _prev_node, _path_length, _status}, acc ->
              value + acc
            end)

          {v, prev_node, path_length, status} = List.last(nodes)
          {value, v, prev_node, path_length, status}
        end
      end)
      |> then(fn node ->
        {coordinates, node}
      end)
    end)
    # remove out of bounds
    |> Enum.reject(&(&1 |> elem(1) |> is_nil()))
    # filter only unvisited
    |> Enum.reject(fn {_, {_, _, _, _, status}} -> status == :visited end)
    # filter only ones with path shorter than current known path
    |> Enum.filter(fn {_coordinates, {value, _v, _prev_node, path_length, _status}} ->
      value + current_path_length < path_length
    end)
    |> Enum.map(fn {coordinates, {value, v, _prev_node, _, status}} ->
      # replace prev element and path length on new nodes
      {coordinates, {v, {x, y, direction}, current_path_length + value, status}}
    end)
    |> then(fn next_steps ->
      # get new steps for next iteration
      new_nodes =
        next_steps
        |> Enum.map(fn {{x, y, direction}, {_, _, path, status}} ->
          {x, y, direction, path, status}
        end)
        # concat with other ones, sort and dedup by path length
        |> Enum.concat(remaining_nodes)
        |> Enum.sort_by(fn {_x, _y, _direction, path, _} -> path end)
        |> Enum.uniq_by(fn {x, y, direction, _path, _} -> {x, y, direction} end)

      new_entrees =
        next_steps
        |> Map.new()
        |> Map.put(
          {x, y, direction},
          {current_step_value, prev_node, current_path_length, :visited}
        )

      # merge new entrees into nodes_map
      nodes_map
      |> Map.merge(new_entrees)
      |> dijkstra(new_nodes, delta_range)
    end)
  end

  def opposite("<"), do: ">"
  def opposite(">"), do: "<"
  def opposite("^"), do: "v"
  def opposite("v"), do: "^"

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
    end)
    |> then(fn entrees ->
      # for each point, make it actually 4 separate points with different points of entry possible
      [">", "<", "^", "v"]
      |> Enum.flat_map(fn direction ->
        Enum.map(entrees, fn {{x, y}, value} ->
          {{x, y, direction}, value}
        end)
      end)
    end)
    |> Map.new()
  end
end
