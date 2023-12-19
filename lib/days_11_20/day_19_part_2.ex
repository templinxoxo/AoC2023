defmodule Day19.Part2 do
  def execute(data \\ fetch_data()) do
    data
    |> Day19.parse_input()
    |> then(fn {workflows, _items} ->
      workflows
      |> Enum.flat_map(&untangle_workflow/1)
      |> Map.new()
    end)
    |> search_ranges([
      %{
        "workflow" => "in",
        "x" => 1..4000,
        "m" => 1..4000,
        "a" => 1..4000,
        "s" => 1..4000
      }
    ])
    |> Enum.filter(&(&1["workflow"] == :accept))
    |> Enum.map(fn %{"x" => x, "m" => m, "a" => a, "s" => s} ->
      [x, m, a, s]
      |> Enum.map(&Range.size/1)
      |> Enum.reduce(&(&1 * &2))
    end)
    |> Enum.sum()
  end

  @doc """
  Instead of standard items as a param take items with ranges as each param values
  Then for each of such ranges -> run single result workflows (see untangle_workflow doc below)
  Each workflow step will split range into 2 ranges or leave it intact.

  Finish running when all ranges reach end (:reject or :accept)
  This will return all possible ranges of numbers that can be put into system to get a result
  """
  def search_ranges(_workflows, []), do: []

  def search_ranges(workflows, items) do
    items
    |> Enum.flat_map(fn
      item ->
        # after untangling, each workflow has exactly 1 rule
        [property, value, destination, sign, else_destination] =
          Map.get(workflows, item["workflow"])

        # with this rules property, get item's appropriate range and
        # split it into 2(or not) based on threshold value
        item
        |> Map.get(property)
        |> split_range(value, sign)

        # get new destinations for each of new ranges
        |> Enum.map(fn range ->
          cond do
            sign == ">" and range.first > value -> destination
            sign == "<" and range.last < value -> destination
            true -> else_destination
          end
          # determine if reached end or another workflow
          |> case do
            "A" -> :accept
            "R" -> :reject
            workflow_id -> workflow_id
          end
          |> then(&{range, &1})
        end)

        # put destination and new ranges back into initial items
        |> Enum.map(fn {range, destination} ->
          item
          |> Map.put("workflow", destination)
          |> Map.put(property, range)
        end)
    end)
    |> Enum.split_with(&(&1["workflow"] in [:accept, :reject]))
    |> then(fn {finished_items, remaining_items} ->
      finished_items ++ search_ranges(workflows, remaining_items)
    end)
  end

  def split_range(range, value, _) when value < range.first or value > range.last, do: [range]

  def split_range(range, value, ">"),
    do: [range.first..value, (value + 1)..range.last] |> remove_negative_ranges()

  def split_range(range, value, "<"),
    do: [range.first..(value - 1), value..range.last] |> remove_negative_ranges()

  def remove_negative_ranges(ranges), do: Enum.reject(ranges, &(&1.step < 0))

  @doc """
  untangle multi level workflows into multiple 1 level workflows (id,condition,destination,else_destination)
    id{x>2000:A,m>2000:A,a>2000:A,s>2000:A,R}
  is equal in results to
    id{x>2000:A,id1}
    id1{m>2000:A,id11}
    id11{a>2000:A,id111}
    id111{s>2000:A,R}
  And notation like that will simplify processing for the algorithm
  """
  def untangle_workflow({id, [rule1, [_destination] = rule2]}) do
    # if only 2 rules in workflow -> concat them
    [{id, rule1 ++ rule2}]
  end

  def untangle_workflow({id, [rule1 | remaining_rules]}) do
    # if workflow has more items, create a new workflow entry for remaining rules and add it's id as a
    # secondary option for 1st one
    new_workflow_id = id <> "1"

    [
      {id, rule1 ++ [new_workflow_id]}
    ] ++ untangle_workflow({new_workflow_id, remaining_rules})
  end

  def fetch_data(), do: Day19.fetch_data()
end
