defmodule Day9 do
  # execute methods

  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> Enum.map(fn line -> get_next_value_from_change_sequence(line, :forward) end)
    |> Enum.sum()
  end

  def execute_part_2(data \\ fetch_data()) do
    data
    |> parse_input()
    |> Enum.map(fn line -> get_next_value_from_change_sequence(line, :backward) end)
    |> Enum.sum()
  end

  def get_next_value_from_change_sequence(sequence, direction) do
    # calculate change between each pair of numbers
    next_sequence =
      sequence
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [a, b] ->
        b - a
      end)

    reached_end = Enum.all?(next_sequence, &(&1 === 0))

    cond do
      # if reached all 0s, return last value from original sequence
      reached_end and direction === :forward ->
        List.last(sequence)

      reached_end and direction === :backward ->
        List.first(sequence)

      direction === :forward ->
        # sum current last number and next value from sequence
        List.last(sequence) +
          get_next_value_from_change_sequence(next_sequence, direction)

      direction === :backward ->
        # subtract next value from sequence from current last number
        List.first(sequence) -
          get_next_value_from_change_sequence(next_sequence, direction)
    end
  end

  # helpers
  def fetch_data() do
    Api.get_input(9)
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.trim()
      |> String.split(" ")
      |> Enum.map(&String.to_integer(&1))
    end)
  end
end
