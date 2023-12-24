defmodule Day23.Part2 do
  def execute() do
    Day23.fetch_data()
    |> execute()
  end

  def execute(data) do
    Timer.time(fn ->
      data
      |> Day23.parse_input()
      |> map_to_crossings_graph()
      |> elem(1)
    end)
  end

  def map_to_crossings_graph({map, start}) do
    map = find_crossings(map)

    crossings =
      map
      |> Enum.filter(fn {_, %{type: type}} -> type == :crossing end)
      |> Enum.map(fn {_, cell} -> cell end)

    # starting with all crossings
    crossings
    |> Enum.map(&[&1])
    |> Enum.concat([[start]])
    # find paths to other nearby crossings -> using pt2 bfs
    |> Day23.bfs(map, %{slope_climb: true, crossing_finish: true})
    # map as list of graph edges
    |> Enum.map(fn path ->
      first = List.first(path)
      last = List.last(path)
      len = length(path) - 1

      %{
        from: first,
        to: last,
        length: len
      }
      |> IO.inspect()
    end)
    |> then(fn edges ->
      IO.inspect(length(edges), label: "edges: ")
      edges
    end)
    |> then(&bfs_edges([{[start], 0}], &1))
  end

  def find_crossings(map) do
    map
    |> Enum.map(fn
      {_, %{type: type}} = element when type in [:forest, :start, :finish] ->
        element

      {coordinates, cell} = element ->
        cell.coordinates
        # for each coordinate, get it's neighbors and move direction
        |> Day23.get_neighbors()
        |> Enum.map(fn {coordinates, _direction} -> Map.get(map, coordinates) end)
        # remove unavailable paths
        |> Enum.reject(&(is_nil(&1) or &1.type == :forest))
        |> length()
        |> case do
          n when n in 0..2 ->
            element

          _ ->
            {coordinates, Map.put(cell, :type, :crossing)}
        end
    end)
    |> Map.new()
  end

  # rewrite
  def bfs_edges(paths, graph, finished_paths \\ {[], 0})

  def bfs_edges([], _graph, finished_path) do
    finished_path
  end

  def bfs_edges(
        [{[%{type: :finish} | _], length} = path | remaining_paths],
        graph,
        {finished_path, current_max_len}
      ) do
    if (current_max_len < length) do
    IO.inspect(length, label: "found new path, length")
      bfs_edges(remaining_paths, graph, path)
    else
      bfs_edges(remaining_paths, graph, {finished_path, current_max_len})
    end
  end

  def bfs_edges(
        [{[current_coordinates | _] = path, path_length} | remaining_paths],
        graph,
        finished_path
      ) do
    current_coordinates.coordinates
    # for each coordinate, get it's neighbors and move direction
    |> get_neighbors(graph)
    # remove unavailable paths
    |> reject_unavailable(path)
    # add available new steps to paths
    |> Enum.map(fn {step, length} -> {[step] ++ path, length + path_length} end)
    |> then(&(remaining_paths ++ &1))
    # take the next steps
    |> bfs_edges(graph, finished_path)
  end

  def reject_unavailable(neighbors, path) do
    Enum.reject(neighbors, fn {elem, _length} ->
      elem_in_path?(path, elem)
    end)
  end

  def elem_in_path?(path, elem) do
    path
    |> Enum.map(& &1.coordinates)
    |> Enum.member?(elem.coordinates)
  end

  def get_neighbors(coordinates, graph),
    do:
      graph
      |> Enum.filter(fn edge -> edge.from.coordinates == coordinates end)
      |> Enum.map(fn edge -> {edge.to, edge.length} end)
end
