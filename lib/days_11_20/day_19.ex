defmodule Day19 do
  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> run_system()
  end

  def run_system({workflows, items}) do
    items
    |> Enum.map(&run_workflows(&1, workflows, "in"))
    |> Enum.map(&grade_item/1)
    |> Enum.sum()
  end

  def run_workflows(item, workflows, current_workflow) do
    workflows
    |> Map.get(current_workflow)
    |> find_destination(item)
    |> case do
      # if finished return :accept or :reject
      "A" -> {:accept, item}
      "R" -> {:reject, item}
      # if string destination is returned - run workflows again with destination workflow
      destination when is_binary(destination) -> run_workflows(item, workflows, destination)
    end
  end

  def find_destination([rule | remaining_rules], item) do
    rule_fun = eval_rule(rule)

    case rule_fun.(item) do
      nil -> find_destination(remaining_rules, item)
      destination -> destination
    end
  end

  # eval rules into functions
  def eval_rule([item]), do: fn _item -> item end

  def eval_rule([property, value, destination, sign]),
    do: fn item ->
      case Map.get(item, property) do
        item_value when sign == ">" and item_value > value -> destination
        item_value when sign == "<" and item_value < value -> destination
        _ -> nil
      end
    end

  def grade_item({:accept, item}), do: item |> Map.values() |> Enum.sum()
  def grade_item({:reject, _}), do: 0

  # helpers
  def fetch_data() do
    Api.get_input(19)
  end

  def parse_input(input) do
    [workflows, items] = String.split(input, "\n\n", trim: true)

    workflows =
      workflows |> String.split("\n", trim: true) |> Enum.map(&parse_workflow/1) |> Map.new()

    items = items |> String.split("\n", trim: true) |> Enum.map(&parse_item/1)
    {workflows, items}
  end

  def parse_workflow(raw_workflow) do
    [name, workflow] = String.split(raw_workflow, ["{", "}"], trim: true)
    rules = workflow |> String.split(",", trim: true) |> Enum.map(&parse_rule/1)
    {name, rules}
  end

  def parse_rule(rule) do
    case String.split(rule, [">", "<", ":"], trim: true) do
      [destination] ->
        [destination]

      [property, value, destination] ->
        sign = String.at(rule, 1)
        value = String.to_integer(value)
        [property, value, destination, sign]
    end
  end

  # json parse item
  def parse_item(raw_item),
    do:
      raw_item
      |> String.split(["{", "}", "=", ","], trim: true)
      |> Enum.chunk_every(2)
      |> Enum.map(fn [key, value] -> {key, String.to_integer(value)} end)
      |> Map.new()
end
