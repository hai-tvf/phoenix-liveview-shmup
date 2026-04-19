defmodule Shmup.Game.PhysicsTest do
  use ExUnit.Case, async: true

  alias Shmup.Game.Physics

  test "clamp_player_center keeps ship inside bounds" do
    {x, y} = Physics.clamp_player_center(240.0, 100.0, 480, 640, 36, 20)
    assert_in_delta x, 240.0, 0.001
    assert_in_delta y, 100.0, 0.001
  end

  test "clamp_player_center pulls center in from edges" do
    {x, _} = Physics.clamp_player_center(0.0, 320.0, 480, 640, 36, 20)
    assert x >= 18.0
    {x2, _} = Physics.clamp_player_center(500.0, 320.0, 480, 640, 36, 20)
    assert x2 <= 480 - 18.0
  end
end
