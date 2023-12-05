defmodule Day5.Part2 do
  def map_final_destination_ranges({seeds, maps}) do
    seed_source_ranges =
      seeds
      |> Enum.chunk_every(2)
      # parse list of seed numbers into list of seed ranges
      # each range contains start number and end number
      |> Enum.map(fn [start, range] -> {start, start + range - 1} end)

    maps
    |> Enum.reduce(seed_source_ranges, fn map, source_ranges ->
      calculate_destination_ranges(source_ranges, map)
    end)
  end

  def calculate_destination_ranges(source_ranges, {_title, map}) do
    # parse map layer transformation to ranges
    # each range contains start number (source range start), end number(source range start + range length)
    # and transformation (destination range start - the source range start)
    map_range_transform =
      map
      |> Enum.map(fn [destination_start, source_start, range] ->
        {source_start, source_start + range - 1, destination_start - source_start}
      end)
      |> Enum.sort_by(fn {start, _end, _transform} -> start end)

    source_ranges
    |> Enum.flat_map(fn {range_start, range_end} = source_range ->
      map_range_transform
      |> filter_overlapping_ranges(source_range)
      |> case do
        [] ->
          # if there are no new ranges, return the original range
          [{range_start, range_end, 0}]

        overlapping_ranges ->
          # else, add opening and closing ranges in case overlapping ranges don't cover the whole source range
          opening_range = calculate_range_opening(overlapping_ranges, source_range)
          closing_range = calculate_range_close(overlapping_ranges, source_range)

          opening_range ++ overlapping_ranges ++ closing_range
      end
    end)
    # move current ranges boundaries by current transform before next layer
    |> Enum.map(fn {range_start, range_end, transform} ->
      {range_start + transform, range_end + transform}
    end)
  end

  defp filter_overlapping_ranges(map_range_transform, {source_start, source_end}),
    do:
      map_range_transform
      # filter ranges to only leave overlapping with source range,
      |> Enum.filter(fn {range_start, range_end, _range_transform} ->
        range_start <= source_end and range_end >= source_start
      end)
      # then cleanup edge ranges not to go over source range boundaries
      |> Enum.map(fn {range_start, range_end, range_transform} ->
        {
          max(range_start, source_start),
          min(range_end, source_end),
          range_transform
        }
      end)

  defp calculate_range_opening(overlapping_ranges, {source_start, _source_end}) do
    overlapping_range_start =
      overlapping_ranges
      |> Enum.map(fn {overlapping_range_start, _overlapping_range_end, _} ->
        overlapping_range_start
      end)
      |> Enum.min()

    # check if any of the ranges start after the source range, if so, add opening range to fill in the gap
    if overlapping_range_start > source_start,
      do: [{source_start, overlapping_range_start - 1, 0}],
      else: []
  end

  defp calculate_range_close(overlapping_ranges, {_source_start, source_end}) do
    overlapping_range_end =
      overlapping_ranges
      |> Enum.map(fn {_overlapping_range_start, overlapping_range_end, _} ->
        overlapping_range_end
      end)
      |> Enum.max()

    # check if any of the ranges end before the source range, if so, add closing range to fill in the gap
    if overlapping_range_end < source_end,
      do: [{overlapping_range_end + 1, source_end, 0}],
      else: []
  end
end
