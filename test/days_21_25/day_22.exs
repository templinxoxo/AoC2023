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

  describe "execute_part_1/1" do
    test "test data" do
      result = Subject.execute_part_1(@test_data)

      assert result == 5
    end

    test "modified test data" do
      result =
        (@test_data <> "\n1,1,10~1,1,10")
        |> Subject.execute_part_1()

      assert result == 5
    end

    test "edge case 1" do
      result =
        """
        0,0,1~0,1,1
        1,1,1~1,1,1
        0,0,2~0,0,2
        0,1,2~1,1,2
        """
        |> Subject.execute_part_1()

      assert result == 3
    end

    test "edge case 2" do
      result =
        """
        0,0,1~1,0,1
        0,1,1~0,1,2
        0,0,5~0,0,5
        0,0,4~0,1,4
        """
        |> Subject.execute_part_1()

      assert result == 2
    end

    test "edge case 3" do
      result =
        """
        0,0,1~2,0,1
        0,2,2~2,2,2
        1,0,4~1,2,4
        """
        |> Subject.execute_part_1()

      assert result == 3
    end

    test "edge case 4" do
      result =
        """
        0,2,3~0,2,4
        0,0,1~0,0,2
        0,0,5~0,2,6
        """
        |> Subject.execute_part_1()

      assert result == 3
    end
  end
end
