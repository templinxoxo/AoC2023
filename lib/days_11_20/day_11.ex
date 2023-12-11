defmodule Day11 do
  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> find_galaxies()
    |> expand_universe(1)
    |> calculate_galaxy_distances_sum()
  end

  def execute_part_2(data \\ fetch_data(), expansion_time \\ 1_000_000) do
    data
    |> parse_input()
    |> find_galaxies()
    # but why tho?
    |> expand_universe(expansion_time - 1)
    |> calculate_galaxy_distances_sum()
  end

  def find_galaxies(galaxy_map) do
    galaxy_map
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y_index} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn
        {".", _} ->
          nil

        {"#", x_index} ->
          {x_index, y_index}
      end)
    end)
    |> Enum.reject(&is_nil/1)
  end

  def expand_universe(galaxy_list, expansion_time \\ 1) do
    empty_x_axis = get_empty_axis(Enum.map(galaxy_list, fn {x, _y} -> x end))
    empty_y_axis = get_empty_axis(Enum.map(galaxy_list, fn {_x, y} -> y end))

    galaxy_list
    |> Enum.map(fn {x, y} ->
      expansion_x = empty_x_axis |> Enum.filter(&(&1 < x)) |> length()
      expansion_y = empty_y_axis |> Enum.filter(&(&1 < y)) |> length()

      {x + (expansion_x * expansion_time), y + expansion_y * expansion_time}
    end)
  end

  def calculate_galaxy_distances_sum(galaxy_list) do
    0..(length(galaxy_list) - 2)
    |> Enum.map(&Enum.slice(galaxy_list, &1, length(galaxy_list)))
    |> Enum.map(fn [{x0, y0} | galaxies] ->
      Enum.map(galaxies, fn {x, y} ->
        abs(x0 - x) + abs(y0 - y)
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def get_empty_axis(galaxies_single_axis) do
    {min_val, max_val} = Enum.min_max(galaxies_single_axis)

    min_val..max_val
    |> Enum.reject(&(&1 in galaxies_single_axis))
  end

  # helpers
  def fetch_data() do
    Api.get_input(11)
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn row ->
      row
      |> String.trim()
      |> String.split("")
      |> Enum.reject(&(&1 == ""))
    end)
  end
end
