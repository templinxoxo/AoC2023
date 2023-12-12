defmodule Day12 do
  # execute methods

  use Memoize

  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> Enum.map(&get_elements_permutations/1)
    |> Enum.sum()
  end

  def execute_part_2(data \\ fetch_data()) do
    timestamp = DateTime.now!("Etc/UTC")

    data
    |> parse_input()
    |> Enum.map(&unfold/1)
    |> Enum.map(&get_elements_permutations/1)
    |> Enum.sum()
    |> then(fn sum ->
      IO.puts(
        "done in #{DateTime.now!("Etc/UTC") |> DateTime.diff(timestamp, :second)}s, result: #{sum}}"
      )

      sum
    end)
  end

  def unfold({elements, group_sizes}) do
    {
      Enum.reduce(1..4, elements, fn _, all_elements -> all_elements ++ ["?"] ++ elements end),
      Enum.reduce(1..4, group_sizes, fn _, all_groups -> all_groups ++ group_sizes end)
    }
  end

  @doc """
  For given data, representing a hot spring search for all possible permutations of unknown elements.
  elements are either:
    . operational
    # damaged
    ? unknown

  group_sizes are the number of damaged elements in a group, separated by at least operational element, ex:
    3, 1, 1 can represent ###.#.#

  This method will return number of all possible permutations for each hot spring
  """
  def get_elements_permutations({elements, []}) do
    if Enum.any?(elements, &(&1 == "#")) do
      #  :error
      0
    else
      #  :end
      1
    end
  end

  defmemo get_elements_permutations({elements, [current_group_size | remaining_groups]}),
    expires_in: :infinity do
    # 1. check what is minimal needed number or elements to fit all the remaining groups
    # sum all remaining elements, adding 1 each time to represent necessary operational elements in between
    min_tail_length = Enum.sum(remaining_groups) + length(remaining_groups)

    # starting at index 0, ending at last index that can potentially fit all remaining groups and current group
    0..(length(elements) - min_tail_length - current_group_size)
    |> Enum.map(fn current_index ->
      # 2. check if after placing current group at current index, all known elements fit
      # if elements fit, take remaining elements and recursively call this method
      if group_can_be_placed_at_index?(elements, current_index, current_group_size) do
        # for placement of group N at index I, number of possible permutations is equal to
        # all permutations of it's remaining elements (and remaining groups).
        # this smaller subset can be passed recursively to the same method
        remaining_elements =
          elements
          |> Enum.slice(current_index + current_group_size, length(elements))
          |> case do
            [] ->
              []

            # if remaining elements start with unknown, replace it with mandatory operational element
            ["?" | rest] ->
              ["."] ++ rest

            ["." | _] = rest ->
              rest
              # remaining group cannot start with damaged element, no need to match agains it
          end

        get_elements_permutations({remaining_elements, remaining_groups})
      else
        0
      end
    end)
    |> Enum.sum()
  end


  def group_can_be_placed_at_index?(elements, current_index, current_group_size) do
    # group can be placed at current index if:
    # - all elements between index and end of group are either damaged or unknown (#, ?)
    # - next element after group end is either operational or unknown (.)
    # - no previous elements before group are damaged (#)
    broken_elements_fit?(elements, current_index, current_group_size) and
      next_operational_element_fits?(elements, current_index, current_group_size) and
      prev_elements_fit?(elements, current_index)
  end

  def broken_elements_fit?(elements, current_index, current_group_size) do
    elements
    |> Enum.slice(current_index, current_group_size)
    |> Enum.all?(&(&1 in ["#", "?"]))
  end

  def next_operational_element_fits?(elements, current_index, current_group_size) do
    next_elem = Enum.at(elements, current_index + current_group_size)
    is_nil(next_elem) or next_elem in [ ".", "?"]
  end

  def prev_elements_fit?(elements, current_index) do
    elements
    |> Enum.take(current_index)
    |> Enum.all?(&(&1 in [".", "?"]))
  end


  # actual logic

  # helpers
  def fetch_data() do
    Api.get_input(12)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [chars | numbers] = String.split(row, [" ", ","], trim: true)

      {
        String.split(chars, "", trim: true),
        Enum.map(numbers, &String.to_integer/1)
      }
    end)
    |> Enum.reject(&(&1 == ""))
  end
end
