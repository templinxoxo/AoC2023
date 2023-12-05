defmodule Day5 do
  # execute methods

  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> map_seeds_to_final_destination()
    |> Enum.min()
  end

  def execute_part_1_ranges(data \\ fetch_data()) do
    {seeds, maps} =
      data
      |> parse_input()

    # to solve pt 1 with using pt2 logic, we need to override seeds
    # now instead of N singular seed numbers, we have N 1-length ranges
    seeds = seeds |> Enum.flat_map(&[&1, 1])

    {seeds, maps}
    |> Day5.Part2.map_final_destination_ranges()
    |> Enum.map(fn {start, _end} -> start end)
    |> Enum.min()
  end

  def execute_part_2(data \\ fetch_data()) do
    data
    |> parse_input()
    |> Day5.Part2.map_final_destination_ranges()
    |> Enum.map(fn {start, _end} -> start end)
    |> Enum.min()
  end

  # actual logic
  def map_seeds_to_final_destination({seeds, maps}) do
    maps
    |> Enum.reduce(seeds, fn map, sources ->
      calculate_destinations(sources, map)
    end)
  end

  def calculate_destinations(sources, {_title, map}) do
    sources
    |> Enum.map(fn source ->
      map
      # for each if source number, check if current source number is within any range of current map layer
      |> Enum.find(fn [_destination_start, source_start, range] ->
        source >= source_start and source < source_start + range
      end)
      |> case do
        # if there is no range match for current source number, return original source number without transformation
        nil ->
          source

        # if there is a range match, calculate the new destination number
        # transformation is calculated as difference between range's source start and destination start
        [destination_start, source_start, _range] ->
          destination_start + source - source_start
      end
    end)
  end

  def fetch_data() do
    Api.get_input(5)
  end

  @doc """
  Parses the Day 5 string input into a tuple, containing seeds and list of mappings between seed and soil.

  example input:
    "
    seeds: 79 14 55 13

    seed-to-soil map:
    50 98 2
    52 50 48

    soil-to-fertilizer map:
    0 15 37
    37 52 2
    39 0 15
    "

  Each line within a map contains three numbers: the destination range start(1), the source range start(2), and the range length(3).

  seeds will be parsed separately from instructions
  for instructions, 1st line is treated as a title, and the rest of the lines are parsed as 3 integer maps (see above)
  """
  def parse_input(input) do
    [seeds | instructions] = split(input, "\n\n")

    maps =
      instructions
      |> Enum.map(fn instruction ->
        [title | maps] = split(instruction, "\n")

        maps = Enum.map(maps, fn map -> map |> split(" ") |> to_numbers() end)

        {title, maps}
      end)

    seeds = seeds |> split(["seeds: ", " "]) |> to_numbers()

    {seeds, maps}
  end

  defp split(string, separator),
    do:
      string
      |> String.trim()
      |> String.split(separator)
      |> Enum.reject(&(&1 == ""))

  defp to_numbers(list), do: Enum.map(list, &String.to_integer(&1))
end
