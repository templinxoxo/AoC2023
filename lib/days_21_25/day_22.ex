defmodule Day22 do
  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> do_tetris_fall()
    |> play_jenga()
    |> length()
  end

  def execute_part_2(data \\ fetch_data()) do
    data
    |> parse_input()
    |> do_tetris_fall()
    |> play_fall_jenga()
  end

  def do_tetris_fall(falling_bricks, fallen_bricks \\ [])

  def do_tetris_fall([], fallen_bricks) do
    # once all bricks fall, order them by z position
    Enum.sort_by(fallen_bricks, & &1.z.first, :asc)
  end

  def do_tetris_fall([brick | falling_bricks], fallen_bricks) do
    fallen_bricks
    |> Enum.find(fn fallen_brick ->
      # find brick that overlaps on x/y asis
      overlaps_with?(fallen_brick, brick)
    end)
    |> case do
      # no brick found, so current one falls to the ground
      nil -> 1
      # a brick found, so current bricks will rest on top
      %{z: _..z} -> z + 1
    end
    |> then(fn z ->
      z_last = Range.size(brick.z) + z - 1

      brick_after_falling = Map.put(brick, :z, z..z_last)
      # after adding new brick to fallen stack, sort them descending by z end position
      fallen_bricks =
        fallen_bricks |> Enum.concat([brick_after_falling]) |> Enum.sort_by(& &1.z.last, :desc)

      do_tetris_fall(falling_bricks, fallen_bricks)
    end)
  end

  def play_jenga(bricks) do
    bricks = get_top_and_bottom_bricks(bricks) |> Enum.map(&{&1.id, &1}) |> Map.new()

    bricks
    |> Enum.reject(fn {_, %{top: top_bricks}} ->
      top_bricks
      |> Enum.reject(fn brick_id ->
        # reject bricks that have other base
        %{bottom: bottom} = Map.get(bricks, brick_id)
        length(bottom) > 1
      end)
      # if any bricks are left, that means they don't have other base
      # current brick will be rejected
      |> Enum.any?()
    end)
  end

  def play_fall_jenga(bricks) do
    bricks = get_top_and_bottom_bricks(bricks) |> Enum.map(&{&1.id, &1}) |> Map.new()

    bricks
    |> Enum.map(fn {_, current_brick} ->
      bricks
      |> get_bricks_to_fall([current_brick.id], Enum.map(current_brick.top, &Map.get(bricks, &1)))
      |> Enum.reject(&(&1 == current_brick.id))
      |> length
    end)
    |> Enum.sum()
  end

  def get_bricks_to_fall(_bricks, fallen_bricks, []) do
    fallen_bricks
  end

  def get_bricks_to_fall(bricks, fallen_bricks, [top_brick | other_bricks]) do
    if top_brick.bottom -- fallen_bricks == [] do
      new_top_bricks = Enum.map(top_brick.top, &Map.get(bricks, &1))

      top_bricks =
        other_bricks
        |> Enum.concat(new_top_bricks)
        |> Enum.sort_by(& &1.z.first, :asc)
        |> Enum.uniq()

      get_bricks_to_fall(bricks, fallen_bricks ++ [top_brick.id], top_bricks)
    else
      get_bricks_to_fall(bricks, fallen_bricks, other_bricks)
    end
  end

  def get_top_and_bottom_bricks(bricks) do
    bricks
    |> Enum.map(fn %{z: first..last} = current_brick ->
      top_bricks =
        bricks
        |> Enum.filter(&(&1.z.first == last + 1 and overlaps_with?(current_brick, &1)))
        |> Enum.map(& &1.id)

      bottom_bricks =
        bricks
        |> Enum.filter(&(&1.z.last == first - 1 and overlaps_with?(current_brick, &1)))
        |> Enum.map(& &1.id)

      Map.merge(current_brick, %{top: top_bricks, bottom: bottom_bricks})
    end)
  end

  def overlaps_with?(brick1, brick2) do
    not Range.disjoint?(brick1.x, brick2.x) and
      not Range.disjoint?(brick1.y, brick2.y)
  end

  # memoize?
  def in_z_index(bricks, z0) do
    Enum.filter(bricks, fn %{z: z} -> z0 in z end)
  end

  # def rests_on_top?(top_brick, bottom_brick) do
  #   overlaps_with?(brick1, brick2) and z_distance(top_brick, bottom_brick) == 1
  # end

  # def z_distance(top_brick, bottom_brick) do
  #   top_brick.z.first - bottom_brick.z.last
  # end

  # helpers
  def fetch_data() do
    Api.get_input(22)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {row, id} ->
      row
      |> String.split("~")
      |> Enum.map(&String.split(&1, ","))
      |> then(fn [start_positions, end_positions] -> Enum.zip(start_positions, end_positions) end)
      |> Enum.map(fn {start_pos, end_pos} ->
        String.to_integer(start_pos)..String.to_integer(end_pos)
      end)
      |> then(fn [x, y, z] ->
        %{
          id: id,
          x: x,
          y: y,
          z: z
        }
      end)
    end)
    |> Enum.sort_by(& &1.z.first, :asc)
  end
end
