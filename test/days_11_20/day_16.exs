defmodule Day16Test do
  use ExUnit.Case

  alias Day16, as: Subject

  @test_data """
  .|...\\....
  |.-.\\.....
  .....|-...
  ........|.
  ..........
  .........\\
  ..../.\\\\..
  .-.-/..|..
  .|....-|.\\
  ..//.|....
  """

  test "execute_part_1/1" do
    result = Subject.execute_part_1(@test_data)

    assert result == 46
  end

  # test "execute_part_2/1" do
  #   result = Subject.execute_part_2(@test_data)

  #   assert result == 0
  # end
end
