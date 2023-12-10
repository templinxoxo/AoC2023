defmodule Day10 do
  # execute methods

  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> find_pipe_line()
    |> then(fn [branch, _] ->
      length(branch) - 1
    end)
  end

  def find_pipe_line(pipes_map) do
    pipes_map
    |> get_pipe_initial_branches()
    |> follow_pipe_connections(pipes_map)
  end

  @doc """
  Starting at "S" point, find possible directions that pipe can branch to
  """
  def get_pipe_initial_branches(pipes_map) do
    pipes_map
    |> List.flatten()
    |> Enum.find(fn
      {"S", _coordinates} -> true
      _ -> false
    end)
    |> then(fn {"S", {x0, y0} = starting_coordinates} ->
      [{x0 + 1, y0}, {x0, y0 + 1}, {x0 - 1, y0}, {x0, y0 - 1}]
      |> Enum.filter(fn coordinates ->
        coordinates
        |> get_pipe(pipes_map)
        # for all 4 directions, check for 2 pipes that include starting coordinates as their connection point
        |> get_pipe_connection_points()
        |> Enum.member?(starting_coordinates)
      end)
      # create initial 2 branches to starting coordinates
      |> Enum.map(&([&1] ++ [starting_coordinates]))
    end)
  end

  @doc """
  For 2 branches, add next connection until both branches get to the same point

  If other than 2 branches are passed, function will error out
  """
  def follow_pipe_connections([[current_node1 | _], [current_node2 | _]] = pipe_branches, _pipes_map)
      when current_node1 == current_node2 do
    pipe_branches
  end

  def follow_pipe_connections([_, _] = pipe_branches, pipes_map) do
    pipe_branches
    |> Enum.map(fn [current_coordinates, previous_coordinates | _rest_of_branch] = branch ->
      current_coordinates
      |> get_pipe(pipes_map)
      |> get_pipe_connection_points()
      |> Enum.reject(&(&1 == previous_coordinates))
      |> Enum.concat(branch)
    end)
    |> follow_pipe_connections(pipes_map)
  end

  def follow_pipe_connections(_pipe_branches, _pipes_map) do
    :error
  end

  def get_pipe({x, y}, pipes_map) do
    pipes_map
    |> Enum.at(y)
    |> Enum.at(x)
  end

  def get_pipe_connection_points({"|", {x, y}}), do: [{x, y + 1}, {x, y - 1}]
  def get_pipe_connection_points({"-", {x, y}}), do: [{x + 1, y}, {x - 1, y}]
  def get_pipe_connection_points({"L", {x, y}}), do: [{x + 1, y}, {x, y - 1}]
  def get_pipe_connection_points({"J", {x, y}}), do: [{x - 1, y}, {x, y - 1}]
  def get_pipe_connection_points({"F", {x, y}}), do: [{x + 1, y}, {x, y + 1}]
  def get_pipe_connection_points({"7", {x, y}}), do: [{x, y + 1}, {x - 1, y}]
  def get_pipe_connection_points({".", _coordinates}), do: []

  # helpers
  def fetch_data() do
    Api.get_input(10)
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.with_index()
    |> Enum.map(fn {row, y_index} ->
      row
      |> String.split("")
      |> Enum.reject(&(&1 == ""))
      |> Enum.with_index()
      |> Enum.map(fn {cell, x_index} ->
        {cell, {x_index, y_index}}
      end)
    end)
  end
end
