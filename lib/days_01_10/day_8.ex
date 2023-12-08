defmodule Day8 do
  # execute methods

  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> move_to_next_node("AAA")
  end

  # actual logic
  def move_to_next_node({_instructions, _network}, "ZZZ", current_steps) do
    current_steps
  end

  def move_to_next_node({instructions, network}, current_node, current_steps \\ 0) do
    index = rem(current_steps, length(instructions))
    instruction = instructions |> Enum.at(index)

    new_node = network |> Map.get(current_node) |> Enum.at(instruction)

    move_to_next_node({instructions, network}, new_node, current_steps + 1)
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
        |> IO.inspect(charlists: :as_lists)
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
