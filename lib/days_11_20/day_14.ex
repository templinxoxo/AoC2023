defmodule Day14 do
  # execute methods

  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> move_up()
    |> weigh()
  end

  def execute_part_2(data \\ fetch_data(), cycles) do
    data
    |> parse_input()
    |> find_rotation_cycle(cycles)
    |> then(fn {cycle_start, cycle_length, results_per_cycle} ->
      remaining_cycles = rem(cycles - cycle_start - 1, cycle_length)

      results_per_cycle |> Map.get(cycle_start + remaining_cycles) |> weigh()
    end)
  end

  @doc """
  find repeating cycle in the rotation of the rows.
  After X cycles, solution will start to repeat itself, with a constant cycle

  To count a result after any number of cycles, we just need to calculate which part of the cycle will be repeated on the given number of cycles.

  returns:
  {cycle_start, cycle_length, results_per_cycle}
  """
  def find_rotation_cycle(rows, max_cycles) do
    find_rotation_cycle(rows, max_cycles, 0, %{})
  end

  def find_rotation_cycle(rows, max_cycles, current_cycle, _solutions)
      when current_cycle > max_cycles do
    {current_cycle, nil, rows}
  end

  def find_rotation_cycle(rows, max_cycles, current_cycle, solutions) do
    solution_key = rows |> List.flatten() |> Enum.join("")

    case Map.get(solutions, solution_key) do
      nil ->
        rows = run_rotation_cycle(rows)

        find_rotation_cycle(
          rows,
          max_cycles,
          current_cycle + 1,
          solutions |> Map.put(solution_key, {current_cycle, rows})
        )

      {cycle, _result} ->
        results_per_cycle =
          solutions
          |> Enum.map(fn {_, {cycle_number, rows}} -> {cycle_number, rows} end)
          |> Map.new()

        {cycle, current_cycle - cycle, results_per_cycle}
    end
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

  def rotate_right(rows) do
    rows
    |> Enum.map(&Enum.reverse(&1))
    |> transpose()
  end

  # for easier test input debugging
  # def print(rows) do
  #   IO.puts("inspecting:")

  #   rows
  #   |> transpose()
  #   |> Enum.each(fn row ->
  #     row |> Enum.join("") |> IO.puts()
  #   end)

  #   IO.puts("")

  #   rows
  # end

  def fetch_data() do
    Api.get_input(14)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> transpose()
  end
end
