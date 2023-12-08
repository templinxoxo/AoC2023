defmodule Day8Test do
  use ExUnit.Case

  alias Day8, as: Subject

  describe "execute_part_1/1" do
    test "case 1" do
      result =
        """
        RL

        AAA = (BBB, CCC)
        BBB = (DDD, EEE)
        CCC = (ZZZ, GGG)
        DDD = (DDD, DDD)
        EEE = (EEE, EEE)
        GGG = (GGG, GGG)
        ZZZ = (ZZZ, ZZZ)
        """
        |> Subject.execute_part_1()

      assert result == 2
    end

    test "case 2" do
      result =
        """
        LLR

        AAA = (BBB, BBB)
        BBB = (AAA, ZZZ)
        ZZZ = (ZZZ, ZZZ)
        """
        |> Subject.execute_part_1()

      assert result == 6
    end
  end

  test "execute_part_2/1" do
    result =
      """
      LR

      11A = (11B, XXX)
      11B = (XXX, 11Z)
      11Z = (11B, XXX)
      22A = (22B, XXX)
      22B = (22C, 22C)
      22C = (22Z, 22Z)
      22Z = (22B, 22B)
      XXX = (XXX, XXX)
      """
      |> Subject.execute_part_2()

    assert result == 6
  end
end
