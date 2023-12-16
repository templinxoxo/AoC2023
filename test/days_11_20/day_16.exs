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

  describe "execute_part_1/1" do
    test "test input" do
      result = Subject.execute_part_1(@test_data)

      assert result == 46
    end

    test "all reflections" do
      result =
        """
        ...\\...
        ././...
        ...\\..\\
        .\\..../
        .......
        """
        |> Subject.execute_part_1()

      assert result == 21
    end

    test "all refractions" do
      result =
        """
        .-.|...
        .....-.
        ...|...
        .-.--|.
        .......
        """
        |> Subject.execute_part_1()

      assert result == 20
    end
  end

  test "execute_part_2/1" do
    result = Subject.brute_force_part_2(@test_data)

    assert result == 51
  end
end
