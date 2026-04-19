defmodule Shmup.Game.Difficulty do
  @moduledoc false

  # Server tick @ 50ms => 20 Hz => 200 ticks = 10s wall-clock in :playing
  @tier_period_ticks 200
  @tier_max 25

  @doc "Ticks of :playing between difficulty tier increases (10s at 20 Hz)."
  def tier_period_ticks, do: @tier_period_ticks

  @doc "Upper cap for tier index (spawn/HP tables clamp to this)."
  def tier_max, do: @tier_max

  @doc "Cooldown between enemy spawns in simulation ticks (lower = more frequent)."
  def spawn_interval(tier) do
    t = min(tier, @tier_max)
    max(15, 55 - t * 2)
  end

  @doc "Maximum simultaneous enemies on screen."
  def max_enemies(tier) do
    t = min(tier, @tier_max)
    min(40, 6 + t * 2)
  end

  @doc "Enemy volley cadence: fire when rem(play_tick, period) == 0."
  def enemy_fire_period(tier) do
    t = min(tier, @tier_max)
    max(8, 50 - t * 2)
  end

  @doc "Base HP for a newly spawned enemy at this tier."
  def enemy_hp(tier) do
    t = min(tier, @tier_max)
    min(12, 1 + div(t, 2))
  end
end
