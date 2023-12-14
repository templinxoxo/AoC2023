defmodule Day14 do
  # execute methods

  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> transpose()
    |> Enum.map(fn column ->
      column
      |> move_up()
      |> weigh()
    end)
    |> Enum.sum()
  end

  def move_up(column) do
    column
    |> Enum.chunk_by(&(&1 == "#"))
    |> Enum.flat_map(fn chunk ->
      chunk
      |> Enum.split_with(&(&1 == "O"))
      |> Tuple.to_list()
      |> List.flatten()
    end)
  end

  def weigh(column) do
    size = length(column)

    column
    |> Enum.with_index()
    |> Enum.map(fn
      {"O", index} -> size - index
      {_, _} -> 0
    end)
    |> Enum.sum()
  end

  # helpers
  def transpose(rows) do
    0..((rows |> List.first() |> length()) - 1)
    |> Enum.map(fn x ->
      0..(length(rows) - 1)
      |> Enum.map(fn y ->
        rows |> Enum.at(y) |> Enum.at(x)
      end)
    end)
  end

  def fetch_data() do
    Api.get_input(14)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end
end
