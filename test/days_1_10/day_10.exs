defmodule Day10Test do
  use ExUnit.Case

  alias Day10, as: Subject

  describe "execute_part_1/1" do
    test "simple case" do
      result =
        """
        -L|F7
        7S-7|
        L|7||
        -L-J|
        L|-JF
        """
        |> Subject.execute_part_1()

      assert result == 4
    end

    test "more complex case" do
      result =
        """
        7-F7-
        .FJ|7
        SJLL7
        |F--J
        LJ.LJ
        """
        |> Subject.execute_part_1()

      assert result == 8
    end
  end
end
