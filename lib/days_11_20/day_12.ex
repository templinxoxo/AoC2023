defmodule Day12 do
  # execute methods

  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> Enum.flat_map(&get_unknown_elements_permutations/1)
    |> length()
  end

  @doc """
  For given data, representing a hot spring search for all possible permutations of unknown elements.
  elements are either:
    . operational
    # damaged
    ? unknown

  group_sizes are the number of damaged elements in a group, separated by at least operational element, ex:
    3, 1, 1 can represent ###.#.#

  This method will return all possible permutations for each hot spring
  """
  def get_unknown_elements_permutations({elements, []}) do
    if Enum.any?(elements, &(&1 == "#")), do: :error, else: :end
  end

  def get_unknown_elements_permutations({elements, [current_group_size | tail]}) do
    # check what is minimal needed number or elements to fit all the tail
    # sum all remaining elements, adding 1 each time to represent necessary operational elements in between
    min_tail_length = tail |> Enum.reduce(0, &(&1 + &2))

    # starting at index 0, ending at last index that can potentially fit all tail and current group
    0..(length(elements) - min_tail_length - current_group_size)
    |> Enum.map(fn current_index ->
      # check if after placing current group at current index, all known elements fit
      all_broken_elements_fit? =
        elements
        |> Enum.slice(current_index, current_group_size)
        |> Enum.all?(&(&1 in ["#", "?"]))

      next_operational_element_fits? =
        elements
        |> Enum.at(current_index + current_group_size)
        |> case do
          nil -> true
          "." -> true
          "?" -> true
          _ -> false
        end

      prev_elements_fit? =
        elements
        |> Enum.take(current_index)
        |> Enum.all?(&(&1 in [".", "?"]))

      # if elements fit, take remaining elements and recursively call this method
      if all_broken_elements_fit? and next_operational_element_fits? and
           prev_elements_fit? do
        # remaining elements to be solved with tail groups
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
          end

        # all elements before current group are operational
        head = elements |> Enum.slice(0, current_index) |> Enum.map(fn _ -> "." end)
        # current group is broken
        group = 1..current_group_size |> Enum.map(fn _ -> "#" end)
        # followed by 1 operational element
        current_group = head ++ group

        # IO.inspect({current_group_size, current_index, remaining_elements, elements, current_group}, label: "hodor")

        case get_unknown_elements_permutations({remaining_elements, tail}) do
          :error ->
            :error

          :end ->
            unused_elements = remaining_elements |> Enum.map(fn _ -> "." end)
            [current_group ++ unused_elements]

          permutations ->
            Enum.map(permutations, &(current_group ++ &1))
        end
      else
        :error
      end
    end)
    |> Enum.reject(&(&1 == :error))
    |> Enum.flat_map(& &1)
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
