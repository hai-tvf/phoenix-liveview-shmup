defmodule Shmup.Game.Physics do
  @moduledoc false

  @doc "Clamp pointer so player center (px, py) stays inside playfield given player size."
  def clamp_player_center(cx, cy, width, height, pw, ph) do
    half_w = pw / 2
    half_h = ph / 2
    nx = cx |> max(half_w) |> min(width - half_w)
    ny = cy |> max(half_h) |> min(height - half_h)
    {nx, ny}
  end

  @doc "Advance one enemy for one tick using movement mode and play time."
  def step_enemy(enemy, play_tick) do
    base_vy = Map.get(enemy, :vy, 1.8)

    case Map.get(enemy, :movement, :straight) do
      :straight ->
        vx = Map.get(enemy, :vx, 0.0)
        %{enemy | x: enemy.x + vx, y: enemy.y + base_vy}

      {:sine, phase0, amp, freq} ->
        vx = amp * :math.cos(play_tick * freq + phase0)
        %{enemy | x: enemy.x + vx, y: enemy.y + base_vy, vx: vx, vy: base_vy}

      {:composite, phase0, amp, freq, wobble} ->
        vx =
          amp * :math.cos(play_tick * freq + phase0) +
            wobble * :math.sin(play_tick * freq * 1.7 + phase0)

        %{enemy | x: enemy.x + vx, y: enemy.y + base_vy, vx: vx, vy: base_vy}
    end
  end
end
