defmodule Day22Test do
  use ExUnit.Case

  alias Day22, as: Subject

  @test_data """
  1,0,1~1,2,1
  0,0,2~2,0,2
  0,2,3~2,2,3
  0,0,4~0,2,4
  2,0,5~2,2,5
  0,1,6~2,1,6
  1,1,8~1,1,9
  """

  test "execute_part_1/1" do
    result = Subject.execute_part_1(@test_data)

    assert result == 5
  end
end
