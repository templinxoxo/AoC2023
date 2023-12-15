defmodule Day15Test do
  use ExUnit.Case

  alias Day15, as: Subject

  @test_data "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"

  test "execute_part_1/1" do
    result = Subject.execute_part_1(@test_data)

    assert result == 1320
  end

  # test "execute_part_2/1" do
  #   result = Subject.execute_part_2(@test_data)

  #   assert result == 0
  # end
end
