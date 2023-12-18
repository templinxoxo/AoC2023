defmodule Day18Test do
  use ExUnit.Case

  alias Day18, as: Subject

  @test_data """
  R 6 (#70c710)
  D 5 (#0dc571)
  L 2 (#5713f0)
  D 2 (#d2c081)
  R 2 (#59c680)
  D 2 (#411b91)
  L 5 (#8ceee2)
  U 2 (#caa173)
  L 1 (#1b58a2)
  U 2 (#caa171)
  R 2 (#7807d2)
  U 3 (#a77fa3)
  L 2 (#015232)
  U 2 (#7a21e3)
  """

  test "execute_part_1/1" do
    result = Subject.execute_part_1(@test_data)

    assert result == 62
  end

  test "execute_part_1/1 - tricky input" do
    #  ┏-----┓ 7
    #  ┃┏--┓.┃ 7
    #  ┃┃  S.┃ 5
    #  ┃┃ ┏┛.┃ 6
    #  ┗┛ ┃..┃ 6
    #     ┗--┛ 4
    result =
      """
      U 1 ()
      L 3 ()
      D 3 ()
      L 1 ()
      U 4 ()
      R 6 ()
      D 5 ()
      L 3 ()
      U 2 ()
      R 1 ()
      U 1 ()
      """
      |> Subject.execute_part_1()

    assert result == 35
  end

  test "execute_part_1/1 - loop input" do
    #  S>-----┓ 8
    #  ┃┏---┓.┃ 8
    #  ┃┃   ┃.┃ 5
    #  ┃┗-┓ ┃.┃ 7
    #  ┃..┃ ┃.┃ 7
    #  ┗--┏-┛.┃ 8
    #     ┃...┃ 5
    #     ┗---┛ 5
    result =
      """
      R 6 ()
      D 7 ()
      L 3 ()
      U 2 ()
      R 1 ()
      U 4 ()
      L 3 ()
      D 2 ()
      R 2 ()
      D 2 ()
      L 3 ()
      U 5 ()
      """
      |> Subject.execute_part_1()

    assert result == 48
  end

  test "execute_part_1/1 - edge case ?" do
    #  S>┓ ┏-┓ 6
    #  ┃.┗-┛.┃ 7
    #  ┃.┏-┓.┃ 7
    #  ┗-┛ ┗-┛ 6
    result =
      """
      R 2 ()
      D 1 {}
      R 2 {}
      U 1 {}
      R 2 {}
      D 3 ()
      L 2 ()
      U 1 ()
      L 2 ()
      D 1 ()
      L 2 ()
      U 3 ()
      """
      |> Subject.execute_part_1()

    assert result == 26
  end

  test "execute_part_2/1" do
    result =
       """
      R 461937 ()
      D 56407 ()
      R 356671 ()
      D 863240 ()
      R 367720 ()
      D 266681 ()
      L 577262 ()
      U 829975 ()
      L 112010 ()
      D 829975 ()
      L 491645 ()
      U 686074 ()
      L 5411 ()
      U 500254 ()
      """
      |> Subject.execute_part_1()

    assert result == 952_408_144_115
  end
end
