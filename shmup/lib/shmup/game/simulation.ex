defmodule Shmup.Game.Simulation do
  @moduledoc false

  alias Shmup.Game.{Collision, Difficulty, GameState, Physics}

  @player_fire_cooldown 10
  @points_per_kill 10

  def step(%GameState{phase: p} = s) when p != :playing, do: s

  def step(%GameState{} = s) do
    s
    |> Map.update!(:tick, &(&1 + 1))
    |> advance_play_time()
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

  defp advance_play_time(%GameState{} = s) do
    play_tick = s.play_tick + 1
    tier = s.difficulty_tier

    tier =
      if play_tick > 0 && rem(play_tick, Difficulty.tier_period_ticks()) == 0 do
        min(tier + 1, Difficulty.tier_max())
      else
        tier
      end

    %{s | play_tick: play_tick, difficulty_tier: tier}
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
    max_e = Difficulty.max_enemies(s.difficulty_tier)

    if length(s.enemies) >= max_e do
      interval = Difficulty.spawn_interval(s.difficulty_tier)
      %{s | enemy_spawn_cd: interval}
    else
      spawn_one_enemy(s)
    end
  end

  defp spawn_one_enemy(%GameState{} = s) do
    margin = 40
    x = margin + rem(s.tick * 7919, max(1, trunc(s.width) - 2 * margin))
    tier = s.difficulty_tier
    id = s.next_id
    mov = movement_for_tier(tier, id)
    hp = Difficulty.enemy_hp(tier)

    enemy = %{
      id: id,
      x: x * 1.0,
      y: 30.0,
      w: 32,
      h: 28,
      vy: 1.8,
      vx: 0.0,
      movement: mov,
      hp: hp
    }

    interval = Difficulty.spawn_interval(tier)

    %{
      s
      | enemies: [enemy | s.enemies],
        enemy_spawn_cd: interval,
        next_id: id + 1
    }
  end

  defp movement_for_tier(tier, id) do
    t = min(tier, Difficulty.tier_max())
    phase0 = id * 0.73

    cond do
      t <= 1 ->
        :straight

      t <= 4 ->
        {:sine, phase0, 2.2 + t * 0.35, 0.085}

      true ->
        {:composite, phase0, 3.5 + min(t, 10) * 0.25, 0.11, 1.2 + t * 0.05}
    end
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

    pt = s.play_tick

    ens =
      Enum.map(s.enemies, fn e ->
        Physics.step_enemy(e, pt)
      end)

    %{s | player_bullets: pbs, enemy_bullets: ebs, enemies: ens}
  end

  defp enemy_fire(%GameState{enemies: []} = s), do: s

  defp enemy_fire(%GameState{play_tick: pt} = s) when pt <= 0, do: s

  defp enemy_fire(%GameState{} = s) do
    period = Difficulty.enemy_fire_period(s.difficulty_tier)

    if rem(s.play_tick, period) != 0 do
      s
    else
      e = List.first(s.enemies)

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
