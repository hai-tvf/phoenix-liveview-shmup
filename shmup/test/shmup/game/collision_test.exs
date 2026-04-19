defmodule Shmup.Game.CollisionTest do
  use ExUnit.Case, async: true

  alias Shmup.Game.Collision

  test "aabb_overlap? detects intersection" do
    a = %{x: 10, y: 10, w: 10, h: 10}
    b = %{x: 12, y: 12, w: 10, h: 10}
    assert Collision.aabb_overlap?(a, b)
  end

  test "aabb_overlap? false when separated" do
    a = %{x: 10, y: 10, w: 10, h: 10}
    b = %{x: 100, y: 100, w: 10, h: 10}
    refute Collision.aabb_overlap?(a, b)
  end

  test "resolve_player_bullets_vs_enemies removes pair and adds score" do
    b = %{x: 50, y: 50, w: 4, h: 10}
    e = %{x: 50, y: 50, w: 32, h: 28}
    {bs, ens, pts} = Collision.resolve_player_bullets_vs_enemies([b], [e], 10)
    assert bs == []
    assert ens == []
    assert pts == 10
  end
end
