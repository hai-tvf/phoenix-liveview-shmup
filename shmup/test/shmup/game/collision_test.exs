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
    e = %{x: 50, y: 50, w: 32, h: 28, hp: 1}
    {bs, ens, pts} = Collision.resolve_player_bullets_vs_enemies([b], [e], 10)
    assert bs == []
    assert ens == []
    assert pts == 10
  end

  test "resolve_player_bullets_vs_enemies decrements hp before kill" do
    b1 = %{x: 50, y: 50, w: 4, h: 10}
    b2 = %{x: 50, y: 50, w: 4, h: 10}
    e = %{x: 50, y: 50, w: 32, h: 28, hp: 2}
    {bs, ens, pts} = Collision.resolve_player_bullets_vs_enemies([b1], [e], 10)
    assert bs == []
    assert length(ens) == 1
    assert hd(ens).hp == 1
    assert pts == 0

    {bs2, ens2, pts2} = Collision.resolve_player_bullets_vs_enemies([b2], ens, 10)
    assert bs2 == []
    assert ens2 == []
    assert pts2 == 10
  end
end
