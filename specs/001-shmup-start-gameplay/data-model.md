# Data Model: Shmup Game (Logical)

Server-side structures (Elixir) are **authoritative**; snapshots may be serialized to JSON for `push_event` to the Hook.

## State machine (session phase)

| Phase      | Description |
|-----------|-------------|
| `splash`  | Shows **BẮT ĐẦU**; high score read from browser hook or initial assign. |
| `playing` | Simulation runs; tick active. |
| `game_over` | Shows final score; update local high score via hook; transition to **splash** (plan default) or overlay (if spec amended). |

## Core struct: `GameState`

| Field | Type / notes |
|-------|----------------|
| `phase` | `:splash \| :playing \| :game_over` |
| `score` | non-negative integer |
| `tick` | integer (monotonic counter per session) |
| `bounds` | `%{width: float, height: float}` playfield size in game units (match client rect scale) |
| `player` | `%Player{}` |
| `player_bullets` | list of `%Bullet{}` |
| `enemies` | list of `%Enemy{}` |
| `enemy_bullets` | list of `%Bullet{}` |
| `rng_seed` | optional; for deterministic tests |
| `input` | latest `%InputFrame{}` from hook (or merged each tick) |

## `Player`

| Field | Description |
|-------|-------------|
| `x`, `y` | Position (e.g. center or top-left; **pick one convention** and use everywhere). |
| `w`, `h` | Hitbox dimensions. |
| `firing` | boolean (derived from last input frame buttons). |

## `Enemy`

| Field | Description |
|-------|-------------|
| `x`, `y` | Position |
| `w`, `h` | Hitbox |
| `hp` | MVP: `1` or omit (one-shot kill) |
| `pattern_id` | optional; identifies spawn/movement pattern |

## `Bullet`

| Field | Description |
|-------|-------------|
| `x`, `y` | Position |
| `vx`, `vy` | Velocity (game units / tick) |
| `owner` | `:player \| :enemy` |

## `InputFrame` (from Hook → `pushEvent`)

| Field | Description |
|-------|-------------|
| `cx`, `cy` | Pointer position relative to playfield, **already clamped** in game coordinates |
| `buttons` | bitmask or `{primary: bool}` for hold-to-fire |
| `seq` | optional monotonic id for ordering |

## Client: `HighScore` (browser only)

| Field | Description |
|-------|-------------|
| `value` | integer; best score achieved |

Not stored on server; persisted via **`localStorage`** from JS as required by spec.

## Validation rules

- Clamp: `0 <= cx <= bounds.width`, `0 <= cy <= bounds.height` (or height/y convention per axis choice).
- On transition to `game_over`, compute `max(previous_high, score)` for persistence.
