defmodule Day13 do
  # execute methods

  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> Enum.map(&find_mirror_index/1)
    |> Enum.map(&summarize/1)
    |> Enum.sum()
  end

  def execute_part_2(data \\ fetch_data()) do
    data
    |> parse_input()
    |> Enum.map(&find_mirror_index(&1, 1))
    |> Enum.map(&summarize/1)
    |> Enum.sum()
  end

  def find_mirror_index(rows, admissible_reflection_error \\ 0) do
    case check_vertical_reflections(rows, admissible_reflection_error) do
      nil ->
        {:horizontal,
         rows |> transpose() |> check_vertical_reflections(admissible_reflection_error)}

      result ->
        {:vertical, result}
    end
  end

  def check_vertical_reflections(rows, admissible_reflection_error) do
    1..(length(rows) - 1)
    |> Enum.find(fn index -> reflections_match?(rows, index, admissible_reflection_error) end)
  end

  def reflections_match?(rows, index, admissible_reflection_error) do
    {current_rows, next_rows} = Enum.split(rows, index)
    max_len = min(length(current_rows), length(next_rows))

    # change list of rows into list of individual items -> comparison is the same, we are just going more granular
    next_rows = Enum.take(next_rows, max_len) |> Enum.join("") |> String.split("", trim: true)

    current_rows =
      current_rows
      |> Enum.reverse()
      |> Enum.take(max_len)
      |> Enum.join("")
      |> String.split("", trim: true)

    Enum.zip(current_rows, next_rows)
    |> Enum.filter(fn {a, b} -> a != b end)
    |> length() ==
      admissible_reflection_error
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
