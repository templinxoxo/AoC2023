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

  describe "execute_part_2/1" do
    test "inside loop" do
      result =
        """
        ..........
        .S------7.
        .|F----7|.
        .||....||.
        .||....||.
        .|L-7F-J|.
        .|..||..|.
        .L--JL--J.
        ..........
        """
        |> Subject.execute_part_2()

      assert result == 4
    end

    test "larger example" do
      result =
        """
        .F----7F7F7F7F-7....
        .|F--7||||||||FJ....
        .||.FJ||||||||L7....
        FJL7L7LJLJ||LJ.L-7..
        L--J.L7...LJS7F-7L7.
        ....F-J..F7FJ|L7L7L7
        ....L7.F7||L7|.L7L7|
        .....|FJLJ|FJ|F7|.LJ
        ....FJL-7.||.||||...
        ....L---J.LJ.LJLJ...
        """
        |> Subject.execute_part_2()

      assert result == 8
    end

    test "example with other junk" do
      result =
        """
        FF7FSF7F7F7F7F7F---7
        L|LJ||||||||||||F--J
        FL-7LJLJ||||||LJL-77
        F--JF--7||LJLJ7F7FJ-
        L---JF-JLJ.||-FJLJJ7
        |F|F-JF---7F7-L7L|7|
        |FFJF7L7F-JF7|JL---7
        7-L-JL7||F7|L7F-7F7|
        L.L7LFJ|||||FJL7||LJ
        L7JLJL-JLJLJL--JLJ.L

        """
        |> Subject.execute_part_2()

      assert result == 10
    end
  end
end
