defmodule Day8 do
  # execute methods

  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> steps_to_final_node("AAA")
  end

  def execute_part_2(data \\ fetch_data()) do
    data
    |> parse_input()
    |> get_pattern_for_starting_nodes()
    |> get_least_common_multiple()
  end

  def steps_to_final_node({instructions, network}, current_node, current_steps \\ 0) do
    if String.ends_with?(current_node, "Z") do
      current_steps
    else
      index = rem(current_steps, length(instructions))
      instruction = instructions |> Enum.at(index)
      new_node = network |> Map.get(current_node) |> Enum.at(instruction)

      steps_to_final_node({instructions, network}, new_node, current_steps + 1)
    end
  end

  def get_pattern_for_starting_nodes({instructions, network}) do
    network
    |> Map.keys()
    |> Enum.filter(&String.ends_with?(&1, "A"))
    |> Enum.map(fn start_node ->
      steps_to_final_node({instructions, network}, start_node)
    end)
  end

  # non optimal solution -> look up wikipedia for better implementation
  def get_least_common_multiple(numbers) do
    leading_number = Enum.max(numbers)
    get_least_common_multiple(numbers, leading_number, leading_number)
  end

  def get_least_common_multiple(numbers, leading_number, multiple) do
    if Enum.all?(numbers, &(rem(multiple, &1) === 0)) do
      multiple
    else
      get_least_common_multiple(numbers, leading_number, multiple + leading_number)
    end
  end

  # helpers
  def fetch_data() do
    Api.get_input(8)
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n\n")
    |> then(fn [instructions, network] ->
      instructions =
        instructions
        |> String.replace("R", "1")
        |> String.replace("L", "0")
        |> String.split("")
        |> Enum.reject(&(&1 == ""))
        |> Enum.map(&String.to_integer/1)

      network =
        Regex.scan(~r/\w+/, network)
        |> List.flatten()
        |> Enum.chunk_every(3)
        |> Enum.map(fn [node | paths] -> {node, paths} end)
        |> Map.new()

      {instructions, network}
    end)
  end
end
