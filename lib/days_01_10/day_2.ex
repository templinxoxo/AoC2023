defmodule Day2 do
  # execute methods
  def execute_part_1() do
    Api.get_input(2)
    |> execute_part_1()
  end

  def execute_part_1(data) do
    data
    |> parse_input()
    |> get_possible_games_sum()
  end

  def execute_part_2() do
    Api.get_input(2)
    |> execute_part_2()
  end

  def execute_part_2(data) do
    data
    |> parse_input()
    |> get_games_min_power()
  end

  # actual logic
  @max_cubes %{
    "red" => 12,
    "green" => 13,
    "blue" => 14
  }

  def get_possible_games_sum(games) do
    games
    |> Enum.reject(fn {_game_number, plays} ->
      Enum.any?(plays, fn cubes ->
        Enum.any?(cubes, fn {color, number} ->
          number > @max_cubes[color]
        end)
      end)
    end)
    |> Enum.map(fn {game_number, _} -> game_number end)
    |> Enum.sum()
  end

  def get_games_min_power(games) do
    games
    |> Enum.map(&get_lowest_game_power/1)
    |> Enum.sum()
  end

  def get_lowest_game_power({_, plays}) do
    plays
    |> List.flatten()
    |> Enum.group_by(fn {color, _number} -> color end)
    |> Enum.map(fn {_color, picks} ->
      picks
      |> Enum.map(fn {_color, number} -> number end)
      |> Enum.max()
    end)
    |> Enum.reduce(1, &(&1 * &2))
  end

  # helpers
  def parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn line ->
      ["Game " <> game_number, plays] = String.split(line, ": ")

      plays =
        plays
        |> String.split("; ")
        |> Enum.map(fn play ->
          play
          |> String.split(", ")
          |> Enum.map(fn cube ->
            [count, color] = String.split(cube, " ")
            {color, String.to_integer(count)}
          end)
        end)

      {String.to_integer(game_number), plays}
    end)
  end
end
