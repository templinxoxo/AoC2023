defmodule Day4 do
  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> get_numbers_intersection_size()
    |> Enum.map(fn
      {_card_number, 0} -> 0
      {_card_number, winning_numbers_count} -> 2 ** (winning_numbers_count - 1)
    end)
    |> Enum.sum()
  end

  def execute_part_2(data \\ fetch_data()) do
    data
    |> parse_input()
    |> get_numbers_intersection_size()
    |> get_final_cards_pile()
    |> Map.values()
    |> Enum.sum()
  end

  def get_numbers_intersection_size(data) do
    data
    |> Enum.map(fn {number, winning, actual} ->
      {number,
       MapSet.new(winning)
       |> MapSet.intersection(MapSet.new(actual))
       |> MapSet.size()}
    end)
  end

  def get_final_cards_pile(initial_cards) do
    initial_cards_pile =
      initial_cards
      |> Enum.map(fn {number, _} -> {number, 1} end)
      |> Map.new()

    initial_cards
    |> Enum.reduce(initial_cards_pile, fn
      {_card_number, 0}, cards_pile ->
        cards_pile

      {card_number, winning_numbers_count}, cards_pile ->
        (card_number + 1)..(card_number + winning_numbers_count)
        |> Enum.map(fn card_n ->
          {card_n, Map.get(cards_pile, card_number)}
        end)
        |> Map.new()
        |> Map.merge(
          cards_pile,
          fn _card_number, current_value, new_value ->
            current_value + new_value
          end
        )
    end)
  end

  # helpers
  def fetch_data() do
    Api.get_input(4)
  end

  def parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn line ->
      [number, winning, actual] = line |> String.trim() |> String.split([": ", " | "])

      {
        number |> String.replace("Card ", "") |> String.trim() |> String.to_integer(),
        winning |> String.split(" ") |> Enum.reject(&(&1 == "")),
        actual |> String.split(" ") |> Enum.reject(&(&1 == ""))
      }
    end)
  end
end
