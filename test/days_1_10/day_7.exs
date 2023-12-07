defmodule Day7Test do
  use ExUnit.Case

  alias Day7, as: Subject

  @test_data """
  32T3K 765
  T55J5 684
  KK677 28
  KTJJT 220
  QQQJA 483
  """

  describe "execute_part_1/1" do
    test "order sample cards - 4 of a kind" do
      cards = """
      33332 10
      2AAAA 1
      """

      result = Subject.execute_part_1(cards)

      # 3332 will trump 2AAAA
      assert result == 21
    end

    test "order sample cards - full house" do
      cards = """
      77888 10
      77788 1
      """

      result = Subject.execute_part_1(cards)

      # 3332 will trump 2AAAA
      assert result == 21
    end

    test "test input" do
      result = Subject.execute_part_1(@test_data)

      assert result == 6440
    end
  end
end
