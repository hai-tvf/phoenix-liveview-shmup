# Phase 0 Research: Shmup LiveView + Hooks

## 1. Toolchain: Mise + Erlang + Elixir

**Decision**: Use **Mise** (`https://mise.jdx.dev/`) to install and pin **Erlang** and **Elixir** to the newest stable versions compatible with the target **Phoenix** release.

**Rationale**: Reproducible dev environments; single tool for runtime versions; aligns with user request.

**Alternatives considered**: asdf (similar); apt/brew (less reproducible per project); Docker-only (heavier for daily `mix` workflow).

**Concrete steps** (adjust versions after `mise ls-remote`):

- Install Mise per upstream docs, then e.g. `mise use -g erlang@<latest>` `elixir@<latest>` or project-local `.mise.toml`.
- Run `mix local.hex` / `mix archive.install hex phx_new` before `mix phx.new`.

**NEEDS CLARIFICATION resolved**: Not left open—exact OTP digits are pinned at bootstrap time in `.mise.toml`.

---

## 2. Phoenix scaffold: `--no-ecto`

**Decision**: `mix phx.new shmup --no-ecto` (name adjustable).

**Rationale**: Spec + constitution exclude DB persistence for scores; removes Ecto/Repo noise.

**Alternatives considered**: Full Phoenix with Ecto (rejected: unused); API-only (rejected: need LiveView UI).

---

## 3. Real-time JS ↔ Elixir: LiveView Hooks

**Decision**: Attach a **`phx-hook`** (e.g. `GameHook`) to the playfield container. The hook:

1. Listens for **`mousemove`**, **`mousedown`**, **`mouseup`** (and optionally **`mouseleave`**) relative to the playfield bounding rect.
2. **Clamps** coordinates to the playfield in JS for immediate UX consistency; server **re-clamps** in pure `Game` code for authority.
3. Sends **`pushEvent("input", payload)`** at a **throttled** rate (e.g. every frame via `requestAnimationFrame` coalescing, or ≤ 60 Hz timer)—not raw `mousemove` spam.
4. Receives **`this.handleEvent` callbacks** from the server for **`push_event(socket, "frame", payload)`** (or `"state"`) each simulation tick with a compact snapshot for rendering (entities + score + phase).

**Rationale**: Meets user requirement for **Hooks** for real-time exchange; keeps simulation **on the server** (constitution); avoids routing every pointer move as a full LiveView event at DOM frequency.

**Alternatives considered**:

- `phx-click` / `phx-track-static` only — **rejected**: insufficient for smooth pointer streaming.
- Full client-side game loop — **rejected**: violates authoritative Elixir core.
- Channels only (no LiveView) — **rejected**: spec is LiveView-first; Hook + LiveView is the idiomatic bridge.

---

## 4. Server tick cadence

**Decision**: **`handle_info(:tick, socket)`** (or `Process.send_after` loop) at **~20–30 ms** (~33–50 Hz) for MVP; measure CPU and adjust.

**Rationale**: Constitution requires explicit cadence; shmup MVP does not need 60 Hz server tick if hook input is smooth.

**Alternatives considered**: 60 Hz server tick — defer until profiling shows need.

---

## 5. Rendering strategy

**Decision (MVP)**: **Hook-driven canvas or SVG** fed by **`push_event` JSON** each tick; HUD text (score) can remain LiveView assigns for simplicity **or** be included in the same snapshot for one paint path.

**Rationale**: Minimizes large HEEx diffs for dozens of bullets; aligns with performance principle.

**Alternatives considered**: Pure HEEx positioned divs for all entities — acceptable early prototype but risk of diff cost at scale.

---

## 6. Browser high score

**Decision**: **`localStorage`** key namespaced by app (e.g. `shmup:high_score`); read on mount, write on **game over** when new record.

**Rationale**: Matches FR-006; no server round-trip.

**Security note**: Treat as untrusted display data; no impact on server.
