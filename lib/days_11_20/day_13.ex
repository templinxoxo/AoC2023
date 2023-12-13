defmodule Day13 do
  # execute methods

  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> Enum.map(&find_mirror_index/1)
    |> Enum.map(&summarize/1)
    |> Enum.sum()
  end

  def find_mirror_index(rows) do
    case check_vertical_reflections(rows) do
      nil -> {:horizontal, rows |> transpose() |> check_vertical_reflections()}
      result -> {:vertical, result}
    end
  end

  def check_vertical_reflections(rows) do
    1..(length(rows) - 1)
    |> Enum.find(fn index -> reflections_match?(rows, index) end)
  end

  def reflections_match?(rows, index) do
    {current_rows, next_rows} = Enum.split(rows, index)
    max_len = min(length(current_rows), length(next_rows))

    Enum.take(next_rows, max_len) == current_rows |> Enum.reverse() |> Enum.take(max_len)
  end

  def transpose(rows) do
    row_length = rows |> List.first() |> String.length()

    0..(row_length - 1)
    |> Enum.map(fn index ->
      rows |> Enum.map(fn row -> String.at(row, index) end) |> Enum.join("")
    end)
  end

  def summarize({:horizontal, number}), do: number
  def summarize({:vertical, number}), do: 100 * number

  # helpers
  def fetch_data() do
    Api.get_input(13)
  end

  def parse_input(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
  end
end
