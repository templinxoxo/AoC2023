defmodule Day1 do
  # execute methods
  def execute_part_1() do
    Api.get_input(1)
    |> execute_part_1()
  end

  def execute_part_1(data) do
    data
    |> parse_input()
    |> Enum.map(&find_digits(&1))
    |> Enum.sum()
  end

  def execute_part_2() do
    Api.get_input(1)
    |> execute_part_2()
  end

  def execute_part_2(data) do
    data
    |> parse_input()
    |> Enum.map(&find_digits_from_words(&1))
    |> Enum.sum()
  end

  # actual logic
  def find_digits(line) do
    scan = Regex.scan(~r/(\d)/, line)
    digits = Enum.map(scan, &(&1 |> List.first() |> String.to_integer()))

    10 * List.first(digits) + List.last(digits)
  end

  def find_digits_from_words(line) do
    scan = Regex.scan(~r/(\d|one|two|three|four|five|six|seven|eight|nine)/, line)
    digits = Enum.map(scan, &(&1 |> List.first() |> to_int()))

    10 * List.first(digits) + List.last(digits)
  end

  def to_int("one"), do: 1
  def to_int("two"), do: 2
  def to_int("three"), do: 3
  def to_int("four"), do: 4
  def to_int("five"), do: 5
  def to_int("six"), do: 6
  def to_int("seven"), do: 7
  def to_int("eight"), do: 8
  def to_int("nine"), do: 9
  def to_int(digit), do: String.to_integer(digit)

  # helpers
  def parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end
end
