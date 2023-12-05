defmodule Day5 do
  # execute methods

  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> map_seeds_to_final_destination()
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
      |> Enum.find(fn [_destination_start, source_start, range] ->
        source >= source_start and source < source_start + range
      end)
      |> case do
        nil ->
          source

        [destination_start, source_start, _range] ->
          destination_start + source - source_start
      end
    end)
  end

  # helpers
  def fetch_data() do
    Api.get_input(5)
  end

  def parse_input(input) do
    [{seeds, _} | maps] =
      input
      |> String.split("\n\n")
      |> Enum.map(fn instruction ->
        [title | maps] =
          instruction
          |> String.trim()
          |> String.split("\n")
          |> Enum.reject(&(&1 == ""))

        maps =
          maps
          |> Enum.map(fn map ->
            map
            |> String.trim()
            |> String.split(" ")
            |> Enum.reject(&(&1 == ""))
            |> Enum.map(&String.to_integer(&1))
          end)

        {title, maps}
      end)
      |> Enum.reject(&(&1 == ""))

    seeds =
      seeds
      |> String.replace("seeds: ", "")
      |> String.split(" ")
      |> Enum.map(&String.to_integer(&1))

    {seeds, maps}
  end
end
