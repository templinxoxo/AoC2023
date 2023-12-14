defmodule Day14 do
  # execute methods

  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> transpose()
    |> move_up()
    |> weigh()
    |> Enum.sum()
  end

  # def execute_part_2(data, cycles) do
  #   data
  #   |> execute_part_2_test(cycles)
  # end

  def execute_part_2_test(data \\ fetch_data(), cycles) do
    data
    |> parse_input()
    |> transpose()
    |> then(fn rows ->
      1..cycles
      |> Enum.reduce(rows, fn _, rows ->
        run_rotation_cycle(rows)
        |> print()
      end)
    end)
  end

  def run_rotation_cycle(rows) do
    1..4
    |> Enum.reduce(rows, fn _, rows ->
      rows
      |> move_up()
      |> rotate_right()
    end)
  end

  def move_up(rows) do
    rows
    |> Enum.map(fn row ->
      row
      |> Enum.chunk_by(&(&1 == "#"))
      |> Enum.flat_map(fn chunk ->
        chunk
        |> Enum.split_with(&(&1 == "O"))
        |> Tuple.to_list()
        |> List.flatten()
      end)
    end)
  end

  def weigh(rows) do
    size = length(rows)

    rows
    |> Enum.map(fn row ->
      row
      |> Enum.with_index()
      |> Enum.map(fn
        {"O", index} -> size - index
        {_, _} -> 0
      end)
      |> Enum.sum()
    end)
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

  def rotate_right(rows) do
    rows
    |> Enum.map(&Enum.reverse(&1))
    |> transpose()
  end


  def print(rows) do
    IO.puts("inspecting:")

    rows
    |> transpose()
    |> Enum.each(fn row ->
      row |> Enum.join("") |> IO.puts()
    end)

    IO.puts("")

    rows
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
