defmodule Day23 do
  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> then(fn {map, start} ->
      bfs([[start]], map, slope_clinb: false)
    end)
    |> Enum.map(&(length(&1) - 1))
    |> Enum.max()
  end

  def execute_part_2(data \\ fetch_data()) do
    Timer.time(fn ->
      data
      |> parse_input()
      |> then(fn {map, start} ->
        bfs([[start]], map, slope_climb: true)
      end)
      |> Enum.map(&(length(&1) - 1))
      |> Enum.max()
    end)
  end

  def bfs(paths, map, finished_paths \\ [], opts)

  def bfs([], _map, finished_paths, _opts) do
    finished_paths
  end

  def bfs([[%{type: :finish} | _] = path | remaining_paths], map, finished_paths, opts) do
    bfs(remaining_paths, map, [path | finished_paths], opts)
  end

  def bfs([[current_coordinates | _] = path | remaining_paths], map, finished_paths, opts) do
    current_coordinates.coordinates
    # for each coordinate, get it's neighbors and move direction
    |> get_neighbors()
    |> Enum.map(fn {coordinates, direction} -> {Map.get(map, coordinates), direction} end)
    # remove unavailable paths
    |> reject_unavailable(path, opts)
    # add available new steps to paths
    |> Enum.map(fn {step, _} -> [step] ++ path end)
    |> then(&(remaining_paths ++ &1))
    # take the next steps
    |> bfs(map, finished_paths, opts)
  end

  def reject_unavailable(neighbors, path, opts) do
    slope_climb = Keyword.get(opts, :slope_climb, false)

    Enum.reject(neighbors, fn
      {nil, _direction} ->
        true

      {%{type: :forest}, _direction} ->
        true

      {%{type: :slope, direction: slope_direction}, direction} ->
        is_opposite_direction?(direction, slope_direction) and !slope_climb

      {%{type: :slope}, _direction} ->
        false

      {%{type: :end}, _direction} ->
        true

      {%{type: :path, coordinates: coordinates}, _direction} ->
        path |> Enum.map(& &1.coordinates) |> Enum.member?(coordinates)

      {%{type: :finish}, _direction} ->
        false
    end)
  end

  def is_opposite_direction?(">", "<"), do: true
  def is_opposite_direction?("<", ">"), do: true
  def is_opposite_direction?("v", "^"), do: true
  def is_opposite_direction?("^", "v"), do: true
  def is_opposite_direction?(_, _), do: false

  def get_neighbors({x, y}),
    do: [{{x - 1, y}, "<"}, {{x + 1, y}, ">"}, {{x, y - 1}, "^"}, {{x, y + 1}, "v"}]

  # helpers
  def fetch_data() do
    Api.get_input(23)
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
    |> Map.new()
    |> then(fn map ->
      # update end
      {finish_coordinates, finish_cell} =
        Enum.max_by(map, fn
          {{_, y}, %{type: :path}} -> y
          _ -> -1
        end)

      Map.put(map, finish_coordinates, Map.merge(finish_cell, %{type: :finish}))
    end)
    |> then(fn map ->
      # get start point
      {_, start} =
        Enum.min_by(map, fn
          {{_, y}, %{type: :path}} -> y
          _ -> :infinity
        end)

      {map, start}
    end)
  end

  def parse_cell(".", coordinates),
    do: %{
      type: :path,
      coordinates: coordinates
    }

  def parse_cell(cell, coordinates) when cell in ["<", "^", ">", "v"],
    do: %{
      type: :slope,
      direction: cell,
      coordinates: coordinates
    }

  def parse_cell("S", coordinates),
    do: %{
      type: :start,
      coordinates: coordinates
    }

  def parse_cell("#", coordinates),
    do: %{
      type: :forest,
      coordinates: coordinates
    }
end
