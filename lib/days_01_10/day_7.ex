defmodule Day7 do
  # execute methods

  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> grade_plays_strength()
    |> order()
    |> calculate_winnings()
  end

  def execute_part_2(data \\ fetch_data()) do
    data
    |> replace_jacks_with_jokers()
    |> parse_input()
    |> grade_plays_strength()
    |> order()
    |> calculate_winnings()
  end

  def calculate_winnings(plays) do
    plays
    |> Enum.with_index()
    |> Enum.map(fn {{_cards, bid}, index} -> bid * (index + 1) end)
    |> Enum.sum()
  end

  def grade_plays_strength(plays) do
    Enum.map(plays, fn {cards, bid} -> {grade_cards_strength(cards), bid} end)
  end

  def replace_jacks_with_jokers(input) do
    String.replace(input, "J", "1")
  end

  def order(plays) do
    plays
    |> Enum.sort(:asc)
    |> IO.inspect(charlists: :as_lists, limit: :infinity)
  end

  @doc """
  Group cards by repetitions.
  Returns card strength tuple, where first tuple elem represents type
  and 2nd represents all cards for comparison value

  Cards are then sorted by type and original cards order

  If cards contains jokers, those will mimic the strongest card in the hand
  """
  def grade_cards_strength(cards) do
    jokers_number = cards |> Enum.filter(&(&1 == 1)) |> length()

    strength =
      cards
      |> Enum.reject(&(&1 == 1))
      |> Enum.group_by(& &1)
      |> Enum.map(fn {card, group} -> {Enum.count(group), card} end)
      |> Enum.sort(:desc)
      |> play_jokers(jokers_number)
      |> get_cards_strength()

    {strength, cards}
  end

  # Five of a kind
  def get_cards_strength([{5, _}]), do: 7
  # Four of a kind
  def get_cards_strength([{4, _} | _]), do: 6
  # Full house
  def get_cards_strength([{3, _}, {2, _}]), do: 5
  # Three of a kind
  def get_cards_strength([{3, _} | _]), do: 4
  # Two pair
  def get_cards_strength([{2, _}, {2, _}, _]), do: 3
  # One pair
  def get_cards_strength([{2, _} | _]), do: 2
  # High card
  def get_cards_strength([{1, _} | _]), do: 1

  # only jokers in hand
  def play_jokers([], 5), do: [{5, 1}]

  # add jokers number to highest repetition
  def play_jokers([{repetitions, card} | rest], jokers),
    do: [{repetitions + jokers, card}] ++ rest

  @doc """
  Serializes a list of card combinations
  Makes sure that every hand has list of 5 elements
  This is needed for comparing hands later on

  Erlang sorting needs lists
  """
  # def serialize(hand) do
  # end

  # helpers
  def fetch_data() do
    Api.get_input(7)
  end

  @doc """
  Parses the input containing poker plays and bids
  Each line represents 1 play: 5 cards and bid height, ex:
    "32T3K 765"

  Returns a list of parsed cards
  """
  def parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse_line/1)
  end

  @doc """
  Parses a card input into a tuple of cards and bid.
  Additionally, instead of card figure, individual card value will be returned, ex:
    "32T3K 765"
  will be parsed into:
   {[3, 2, 10, 3, 13], 765}
  """
  def parse_line(line) do
    [cards, bid] = line |> String.split(" ")
    cards = cards |> String.split("") |> Enum.reject(&(&1 == "")) |> Enum.map(&parse_card(&1))
    {cards, String.to_integer(bid)}
  end

  def parse_card("A"), do: 14
  def parse_card("K"), do: 13
  def parse_card("Q"), do: 12
  def parse_card("J"), do: 11
  def parse_card("T"), do: 10
  def parse_card(int), do: String.to_integer(int)
end
