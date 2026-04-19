defmodule Shmup.Game.Simulation do
  @moduledoc false

  alias Shmup.Game.{Collision, GameState, Physics}

  @player_fire_cooldown 10
  @enemy_spawn_interval 55
  @points_per_kill 10

  def step(%GameState{phase: p} = s) when p != :playing, do: s

  def step(%GameState{} = s) do
    s
    |> Map.update!(:tick, &(&1 + 1))
    |> apply_input()
    |> tick_cooldowns()
    |> maybe_spawn_enemy()
    |> fire_player_bullet()
    |> move_all()
    |> enemy_fire()
    |> resolve_hits()
    |> cull_offscreen()
    |> check_player_death()
  end

  defp apply_input(%GameState{} = s) do
    %{cx: cx, cy: cy, primary: _} = s.pending_input
    %{w: pw, h: ph} = s.player
    {nx, ny} = Physics.clamp_player_center(cx, cy, s.width, s.height, pw, ph)
    %{s | player: %{s.player | x: nx, y: ny}}
  end

  defp tick_cooldowns(s) do
    pcd = max(0, s.player_fire_cd - 1)
    esc = max(0, s.enemy_spawn_cd - 1)
    %{s | player_fire_cd: pcd, enemy_spawn_cd: esc}
  end

  defp maybe_spawn_enemy(%GameState{enemy_spawn_cd: cd} = s) when cd != 0, do: s

  defp maybe_spawn_enemy(%GameState{} = s) do
    margin = 40
    # deterministic pseudo-random x from tick
    x = margin + rem(s.tick * 7919, max(1, trunc(s.width) - 2 * margin))

    enemy = %{
      x: x * 1.0,
      y: 30.0,
      w: 32,
      h: 28,
      vy: 1.8,
      vx: 0.0
    }

    %{
      s
      | enemies: [enemy | s.enemies],
        enemy_spawn_cd: @enemy_spawn_interval
    }
  end

  defp fire_player_bullet(%GameState{pending_input: %{primary: false}} = s), do: s

  defp fire_player_bullet(%GameState{player_fire_cd: cd} = s) when cd > 0, do: s

  defp fire_player_bullet(%GameState{player: pl} = s) do
    b = %{
      x: pl.x,
      y: pl.y - pl.h / 2 - 6,
      w: 4,
      h: 10,
      vy: -14.0
    }

    %{
      s
      | player_bullets: [b | s.player_bullets],
        player_fire_cd: @player_fire_cooldown
    }
  end

  defp move_all(%GameState{} = s) do
    pbs =
      Enum.map(s.player_bullets, fn b ->
        %{b | y: b.y + b.vy}
      end)

    ebs =
      Enum.map(s.enemy_bullets, fn b ->
        %{b | y: b.y + b.vy}
      end)

    ens =
      Enum.map(s.enemies, fn e ->
        %{e | y: e.y + e.vy, x: e.x + e.vx}
      end)

    %{s | player_bullets: pbs, enemy_bullets: ebs, enemies: ens}
  end

  defp enemy_fire(%GameState{enemies: ens, tick: t} = s) do
    if rem(t, 50) != 0 or ens == [] do
      s
    else
      e = List.first(ens)

      b = %{
        x: e.x,
        y: e.y + e.h / 2 + 4,
        w: 4,
        h: 10,
        vy: 9.0
      }

      %{s | enemy_bullets: [b | s.enemy_bullets]}
    end
  end

  defp resolve_hits(%GameState{} = s) do
    {pbs, ens, pts} =
      Collision.resolve_player_bullets_vs_enemies(
        s.player_bullets,
        s.enemies,
        @points_per_kill
      )

    %{s | player_bullets: pbs, enemies: ens, score: s.score + pts}
  end

  defp cull_offscreen(%GameState{width: _w, height: h} = s) do
    pbs = Enum.filter(s.player_bullets, fn b -> b.y > -30 end)
    ebs = Enum.filter(s.enemy_bullets, fn b -> b.y < h + 40 end)
    ens = Enum.filter(s.enemies, fn e -> e.y < h + 80 end)
    %{s | player_bullets: pbs, enemy_bullets: ebs, enemies: ens}
  end

  defp check_player_death(%GameState{} = s) do
    if Collision.enemy_hits_player?(s.enemy_bullets, s.player) do
      GameState.new_game_over(s)
    else
      s
    end
  end
end
