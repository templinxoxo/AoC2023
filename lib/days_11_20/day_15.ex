defmodule Day15 do
  # execute methods
  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> Enum.map(&calculate_string_value/1)
    |> Enum.sum()
  end

  def execute_part_2(data \\ fetch_data()) do
    data
    |> parse_input()
    |> Enum.map(&get_lens_command_details/1)
    |> Enum.reduce(%{}, &run_command/2)
    |> calculate_focusing_power()
    |> Enum.sum()
  end

  def get_lens_command_details(string) do
    string
    |> String.split(["=", "-"], trim: true)
    |> case do
      [label] ->
        {label, :remove, calculate_string_value(label)}

      [label, lens] ->
        {label, :place, calculate_string_value(label), String.to_integer(lens)}
    end
  end

  def run_command({label, :place, index, lens}, current_boxes) do
    current_box = Map.get(current_boxes, index, [])

    new_box =
      case Enum.find_index(current_box, fn {lens_label, _} -> lens_label == label end) do
        nil ->
          current_box ++ [{label, lens}]

        lens_index ->
          List.replace_at(current_box, lens_index, {label, lens})
      end

    Map.put(current_boxes, index, new_box)
    # |> print()
  end

  def run_command({label, :remove, index}, current_boxes) do
    current_box = Map.get(current_boxes, index, [])

    case Enum.find_index(current_box, fn {lens_label, _} -> lens_label == label end) do
      nil ->
        current_boxes

      lens_index ->
        current_box = List.delete_at(current_box, lens_index)
        Map.put(current_boxes, index, current_box)
    end

    # |> print()
  end

  def calculate_focusing_power(boxes_map) do
    boxes_map
    |> Enum.flat_map(fn {boxes_index, boxes} ->
      boxes
      |> Enum.with_index()
      |> Enum.map(fn {{_label, lens}, box_index} ->
        lens * (box_index + 1) * (boxes_index + 1)
      end)
    end)
  end

  # def print(map) do
  #   IO.puts("")

  #   map
  #   |> Enum.sort_by(&elem(&1, 0))
  #   |> Enum.each(fn {index, boxes} ->
  #     IO.puts("box #{index}:")
  #     IO.inspect(boxes)
  #   end)

  #   map
  # end

  def calculate_string_value(string) do
    string
    |> String.to_charlist()
    |> Enum.reduce(0, &rem((&1 + &2) * 17, 256))
  end

  # actual logic

  # helpers
  def fetch_data() do
    Api.get_input(15)
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split(",", trim: true)
  end
end
