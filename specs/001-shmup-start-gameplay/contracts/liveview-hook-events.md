# Contract: LiveView ↔ JS Hook (Game)

Phoenix **LiveView** module (e.g. `GameLive`) and **`GameHook`** (assets) exchange data via:

- **Client → server**: `this.pushEvent(target, eventName, payload)`
- **Server → client**: `push_event(socket, eventName, payload)` handled in **`mounted()`** via `this.handleEvent(eventName, callback)`

Names below are **stable API** for this feature; changing them requires updating Hook + LiveView + tests together.

## Client → Server (`pushEvent`)

| Event name | When | Payload (JSON object) |
|------------|------|-------------------------|
| `input` | Throttled pointer/fire updates while `playing` | `cx` (number), `cy` (number), `primary` (boolean, true while hold-to-fire) |
| `high_score_read` | On splash mount (optional) | `{}` or `{ "request": true }` — server may ignore if score stays client-only |
| `high_score_write` | On game over when new record (optional) | `{ "value": <int> }` — **or** keep high score **fully in JS** without these events (simpler; still satisfies spec) |

**Recommendation**: Implement **high score purely in the Hook + `localStorage`**, and keep **`input`** as the only required client→server game event for MVP. Document final choice in tasks.

## Server → Client (`push_event`)

| Event name | When | Payload |
|------------|------|---------|
| `frame` | Each simulation tick while `playing` | `{ "tick": int, "score": int, "entities": [ ... ] }` — shape of `entities` TBD in implementation (minimal list of `{t,x,y,w,h}`) |
| `phase` | Phase changes | `{ "phase": "splash" \| "playing" \| "game_over", "score"?: int }` |

Hook **must** register `handleEvent` for each used name in `mounted()`.

## Ordering & performance

- `input` rate MUST be bounded (see [research.md](../research.md)); server MAY coalesce last frame per tick.
- `frame` rate equals simulation tick (~20–30 Hz MVP).
