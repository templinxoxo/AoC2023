defmodule Day15 do
  # execute methods

  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> Enum.map(&calculate_string_value/1)
    |> Enum.sum()
  end

  def calculate_string_value(string) do
    string
    |> String.to_charlist()
    |> Enum.reduce(0, & rem((&1 + &2) * 17, 256))
  end

  # actual logic

  # helpers
  def fetch_data() do
    Api.get_input(15)
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split(",", trim: true)
  end
end
