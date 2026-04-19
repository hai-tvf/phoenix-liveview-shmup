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
end
