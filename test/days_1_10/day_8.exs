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
end
