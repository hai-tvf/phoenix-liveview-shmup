defmodule Shmup.Game.Collision do
  @moduledoc false

  @doc "Axis-aligned boxes; entities use center (x,y) and half-extents (w,h) as full width/height."
  def aabb_overlap?(
        %{x: x1, y: y1, w: w1, h: h1},
        %{x: x2, y: y2, w: w2, h: h2}
      ) do
    l1 = x1 - w1 / 2
    r1 = x1 + w1 / 2
    t1 = y1 - h1 / 2
    b1 = y1 + h1 / 2
    l2 = x2 - w2 / 2
    r2 = x2 + w2 / 2
    t2 = y2 - h2 / 2
    b2 = y2 + h2 / 2

    not (r1 < l2 or r2 < l1 or b1 < t2 or b2 < t1)
  end

  @doc "On hit, decrements enemy HP; removes enemy and adds score only when HP reaches 0. Bullet is consumed on hit."
  def resolve_player_bullets_vs_enemies(bullets, enemies, points_per_kill \\ 10) do
    Enum.reduce(bullets, {[], enemies, 0}, fn b, {kept, ens, pts} ->
      case Enum.find_index(ens, &aabb_overlap?(b, &1)) do
        nil ->
          {[b | kept], ens, pts}

        idx ->
          enemy = Enum.at(ens, idx)
          hp = Map.get(enemy, :hp, 1) - 1

          cond do
            hp <= 0 ->
              {kept, List.delete_at(ens, idx), pts + points_per_kill}

            true ->
              updated = Map.put(enemy, :hp, hp)
              {kept, List.replace_at(ens, idx, updated), pts}
          end
      end
    end)
    |> then(fn {kb, e, p} -> {Enum.reverse(kb), e, p} end)
  end

  @doc "Returns true if any enemy bullet hits the player."
  def enemy_hits_player?(enemy_bullets, player) do
    Enum.any?(enemy_bullets, fn b -> aabb_overlap?(b, player) end)
  end
end
