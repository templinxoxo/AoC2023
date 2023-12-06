defmodule Day6 do
  # execute methods

  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input_as_separate_numbers()
    |> Enum.map(&get_possible_winning_scenarios(&1))
    |> Enum.reduce(1, &(&1 * &2))
  end

  def execute_part_2(data \\ fetch_data()) do
    data
    |> parse_input_as_single_number()
    |> get_possible_winning_scenarios()
  end


  @doc """
  to get number of winning scenarios, we have to write a bunch of function
    distance = speed * time_left
    speed = time_winding
    time_left = time - time_winding

  after substituting, we get
    distance = time_winding * (time - time_winding)
    distance = time_winding * time - time_winding^2
    time_winding^2 - time_winding * time + distance = 0

  now with this last function, we just need to find the roots of the function
  """
  def get_possible_winning_scenarios({time, distance}) do
    calculate_function_roots(time, distance)
    |> points_between_roots()
  end

  @doc """
  Calculates the roots of the function
    t^2 - time * t + distance = 0
  time and distance are given attributes, so the only unknown is t

  from square function roots formula, we get
    delta = b^2 - 4 * a * c
    x1 = (-b + sqrt(delta)) / (2 * a)
    x2 = (-b - sqrt(delta)) / (2 * a)

  so in our case
    delta = time^2 - 4 * distance
    x1 = time + sqrt(delta) / 2
    x2 = time - sqrt(delta) / 2
  """
  def calculate_function_roots(time, distance) do
    delta = time ** 2 - 4 * distance
    x1 = (time + :math.sqrt(delta)) / 2
    x2 = (time - :math.sqrt(delta)) / 2

    [x1, x2]
  end

  def points_between_roots(roots) do
    x1 = Enum.min(roots) |> then(&(&1 + 1)) |> floor()
    x2 = Enum.max(roots) |> then(&(&1 - 1)) |> ceil()

    x2 - x1 + 1
  end

  # helpers
  def fetch_data() do
    Api.get_input(6)
  end

  @doc """
  Parses the input containing 2 same length lists of numbers
  into 1 list of tuples containing the numbers from the 2 lists (by column), ex:
    "1 2
     3 4"
  will be parsed into
    [{1,3}, {2, 4}]
  """
  def parse_input_as_separate_numbers(input) do
    Regex.scan(~r/(\d+)/, input)
    |> Enum.map(fn [match | _] -> match end)
    |> Enum.map(&String.to_integer/1)
    |> then(&Enum.split(&1, floor(length(&1) / 2)))
    |> then(fn {list1, list2} -> Enum.zip(list1, list2) end)
  end

  @doc """
  Parses the input containing 2 lists of numbers into 2 numbers.
  Each line represents 1 number, spaces and other characters are removed, ex:
    "1 2 3
     3 4 5"
  will be parsed into
    {123, 345}
  """
  def parse_input_as_single_number(input) do
    input
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn line ->
      line
      |> String.replace(~r/\D/, "")
      |> String.to_integer()
    end)
    |> then(fn [num1, num2] -> {num1, num2} end)
  end
end
