defmodule Day10 do
  # execute methods

  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> find_pipe_line()
    |> then(fn {pipe, _} ->
      round((length(pipe) - 1) / 2)
    end)
  end

  def execute_part_2(data \\ fetch_data()) do
    data
    |> parse_input()
    |> find_pipe_line()
    |> count_inside_area()
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
  def follow_pipe_connections(
        [[current_node1 | _] = branch1, [current_node2 | rest_of_branch2]],
        pipes_map
      )
      when current_node1 == current_node2 do
    # glue both branches together into 1 pipe. First and last elements are the starting point
    pipe = branch1 |> Enum.reverse() |> Enum.concat(rest_of_branch2)
    {pipe, pipes_map}
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

  @doc """
  For each row, starting at the :outside and not on pipe border
  check if after the next pipe or empty cell, area will change to :inside
  going on the pipe border and getting off may also change area type, example:
  (o = outside, i = inside)
    o┏━━┛i    outside -> border starting at the bottom and ending on top -> inside
    o┃i       outside -> vertical border -> inside
    o┃i┃o
    o┗━┛o     outside -> border starting at the top and ending on top -> still outside

  checking this way will still work even if intermediate areas have no size, example:
    o┏━━┛┏━━┛o outside -> inside(covering no area) -> outside

    o┃┃┃┃┃i -> multiple outside->inside changes



  This will only work if all but main pipe are removed from the map and
  starting point "S" is replaced with appropriate pipe type (|, -, L, J, F, 7)
  """
  def count_inside_area({pipe, pipes_map}) do
    pipes_map
    |> remove_junk(pipe)
    |> print_pipe(pipe)
    |> Enum.reduce(0, fn row, inside_area_count ->
      {row_inside_area, _, _} =
        row
        # starting outside
        |> Enum.reduce({0, :outside, nil}, fn
          {".", _coordinates}, {count, :inside, nil} ->
            # count every empty cell inside the pipe
            {count + 1, :inside, nil}

          # check if current area of pipe border should change otherwise
          {pipe_type, _coordinates}, {count, current_area, current_pipe} ->
            {next_area, next_border} = check_current_area(pipe_type, current_area, current_pipe)
            {count, next_area, next_border}
        end)

      row_inside_area + inside_area_count
    end)
  end

  @doc """
  This function will
  - replace all pipes that are not connected to main pipe with `.`
  - replace starting node with appropriate pipe type
  """
  def remove_junk(pipes_map, pipe) do
    # 2nd and 2nd to last elements are starting point connections
    starting_coordinates = pipe |> Enum.at(0)

    starting_connections_coordinates =
      [
        Enum.at(pipe, 1),
        Enum.at(pipe, -2)
      ]

    # from all possible pipe types, select which one is the starting pipe
    starting_type =
      ["|", "-", "L", "J", "F", "7"]
      |> Enum.find(fn type ->
        get_pipe_connection_points({type, starting_coordinates})
        |> Enum.all?(&(&1 in starting_connections_coordinates))
      end)

    pipes_map
    |> Enum.map(fn row ->
      row
      |> Enum.map(fn
        {pipe_type, coordinates} ->
          cond do
            pipe_type == "S" ->
              {starting_type, coordinates}

            coordinates in pipe ->
              {pipe_type, coordinates}

            true ->
              {".", coordinates}
          end
      end)
    end)
  end

  @doc """
  Check if current pointer is inside, outside or on border of pipe loop
  Check is done by:
    - pipe type
    - current area: :outside or :inside
    - current pipe: nil, L(beginning on top) of F(beginning on the bottom)

  If there is a current_pipe, only next pipe elements are allowed: -, J, 7
  If pipe ends the same way as it started (F..7 or L..J), current area won't change
  If pipe ends the other way that it started (F..J or L..7), current area will change

  If pipe is vertical, current area will always change, but current pipe is nil (going through the pipe border, not `on` it)
  """
  # change area after meeting vertical pipe
  def check_current_area("|", current_area, nil), do: {change_area(current_area), nil}
  # get on the pipe after meeting pipe border start
  def check_current_area("F", current_area, nil), do: {current_area, "F"}
  def check_current_area("L", current_area, nil), do: {current_area, "L"}
  # continue on the same border after meeting horizontal pipe
  def check_current_area("-", current_area, current_pipe), do: {current_area, current_pipe}
  # get off the border and don't change area after meeting pipe border end in the same direction
  def check_current_area("7", current_area, "F"), do: {current_area, nil}
  def check_current_area("J", current_area, "L"), do: {current_area, nil}
  # get off the border and do change area after meeting pipe border end in the other direction
  def check_current_area("J", current_area, "F"), do: {change_area(current_area), nil}
  def check_current_area("7", current_area, "L"), do: {change_area(current_area), nil}
  # don't change anything when going over empty cell
  def check_current_area(".", current_area, nil), do: {current_area, nil}

  def change_area(:inside), do: :outside
  def change_area(:outside), do: :inside
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

  def print_pipe(pipe_map, pipe) do
    pipe_map
    |> Enum.each(fn row ->
      row
      |> Enum.map(fn {pipe_cell, coordinates} ->
        cond do
          coordinates in pipe -> get_pipe_print(pipe_cell)
          pipe_cell == "." -> " "
          true -> "#"
        end
      end)
      |> Enum.join("")
      |> IO.puts()
    end)

    pipe_map
  end

  def get_pipe_print("S"), do: "o"
  def get_pipe_print("F"), do: "┏"
  def get_pipe_print("J"), do: "┛"
  def get_pipe_print("7"), do: "┓"
  def get_pipe_print("L"), do: "┗"
  def get_pipe_print("|"), do: "┃"
  def get_pipe_print("-"), do: "━"
end
