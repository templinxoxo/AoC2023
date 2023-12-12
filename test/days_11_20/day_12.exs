defmodule Day12Test do
  use ExUnit.Case

  alias Day12, as: Subject

  @test_data """
  ???.### 1,1,3
  .??..??...?##. 1,1,3
  ?#?#?#?#?#?#?#? 1,3,1,6
  ????.#...#... 4,1,1
  ????.######..#####. 1,6,5
  ?###???????? 3,2,1
  """

  describe "execute_part_1/1" do
    test "simple input 1" do
      result = Subject.execute_part_1("?###???????? 3,2,1")

      assert result == 10
    end

    test "simple input 2" do
      result = Subject.execute_part_1("????? 1,1")

      assert result == 6
    end

    test "simple input 3" do
      result = Subject.execute_part_1("?.??#?.????#?????? 4,4")

      assert result == 4
    end
  end

  test "execute_part_1/1" do
    result = Subject.execute_part_1(@test_data)

    assert result == 21
  end

  # test "execute_part_2/1" do
  #   result = Subject.execute_part_2(@test_data)

  #   assert result == 0
  # end
end
