# Implementation Plan: Shmup — Start, Mouse Combat, and Local High Score

**Branch**: `001-shmup-start-gameplay` | **Date**: 2026-04-19 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-shmup-start-gameplay/spec.md` + stack notes: **Mise** for Erlang/Elixir, **`mix phx.new … --no-ecto`**, **LiveView JS Hooks** for real-time JS ↔ Elixir data exchange.

## Summary

Deliver a vertical shmup in a **Phoenix LiveView** app (no Ecto/DB): splash with **BẮT ĐẦU** → playfield with **mouse + hold-to-fire**, **enemy bullets end the run**, **player bullets score on kills**, **local high score** in browser storage. **Pointer coordinates are clamped** to the playfield (spec clarification). **Tooling**: install **latest Erlang + Elixir via Mise**, scaffold with **`mix phx.new <app> --no-ecto`**. **Runtime architecture**: server-authoritative simulation in **pure Elixir modules**; a **LiveView JS Hook** attached to the playfield sends high-rate **pointer / fire** input via `pushEvent`, and receives **state snapshots or draw commands** via `push_event` from the server on a fixed tick—avoid flooding LiveView with one event per DOM mousemove. **Post-game navigation** (clarification Q2 not yet in spec): plan assumes **return to splash** and **BẮT ĐẦU** to play again; amend spec if overlay-retry is preferred.

## Technical Context

**Language/Version**: Elixir and Erlang via **Mise** (pin `erlang` + `elixir` to latest stable channels supported by Mise on the developer OS; record exact versions in `.mise.toml` / `.tool-versions` after install).  
**Primary Dependencies**: Phoenix (with LiveView), `esbuild` asset pipeline (default `mix phx.new`), **no Ecto** (`--no-ecto`).  
**Storage**: **N/A** for gameplay and scores on server (per spec); **browser `localStorage`** (or `sessionStorage` only if product changes) for high score on the client.  
**Testing**: **ExUnit** for pure `Shmup.Game.*` modules; **`Phoenix.LiveViewTest`** smoke tests for splash → play, game over path; **Wallaby** optional later, not required for MVP.  
**Target Platform**: Modern desktop browsers (mouse primary); server: dev on macOS/Linux with `mix phx.server`.  
**Project Type**: Single Phoenix web application (LiveView-first UI).  
**Performance Goals**: Simulation tick **20–30 Hz** on server for MVP (tune 15–60 Hz); hook → server input **throttled** (e.g. ≤ 60 Hz, or `requestAnimationFrame` batching) to avoid overloading the channel.  
**Constraints**: No database; real-time feel via **Hooks + `pushEvent` / `push_event`**; clamp pointer in **both** hook (UX) and server (authoritative) for FR-002.  
**Scale/Scope**: Single session per LiveView; one playfield; MVP entities: player, player bullets, enemies, enemy bullets, score, phases splash | playing | game_over.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Aligned with `.specify/memory/constitution.md` (Phoenix LiveView vertical shmup):

- [x] **LiveView-native surface**: **Authoritative state** in OTP/LiveView process; **`handle_info` `:tick`** (or `Process.send_after`) advances simulation; **Hook** sends `input` events; server **`push_event`** sends render/game snapshots to the hook each tick (see [research.md](./research.md)).
- [x] **Pure game core**: All movement, clamping, spawning, collisions, scoring in **`lib/<app>/game/*.ex`** with no `Phoenix.LiveView` imports; LiveView only orchestrates tick, delegates to `Game.*`, forwards hook payloads.
- [x] **Testing**: ExUnit table tests for collisions and scoring; LiveView tests for **start**, **tick + assign**, **game over** visibility.
- [x] **Performance**: Tick **20–30 Hz** target; **small JSON payloads** on `push_event` (compact entity lists or deltas); avoid full-DOM diff for every entity—prefer **canvas/SVG in hook** driven by snapshot or minimal assigns for HUD only.
- [x] **Incremental scope**: MVP = splash, playfield, one enemy spawn pattern, scoring, game over → splash; no bosses/multiplayer.

**Post Phase 1**: Design above satisfies constitution; no Complexity Tracking table required.

## Project Structure

### Documentation (this feature)

```text
specs/001-shmup-start-gameplay/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md   # /speckit.tasks — not created by this plan
```

### Source Code (after `mix phx.new shmup --no-ecto`)

Phoenix convention (OTP app name `shmup` — adjust if you choose a different app name):

```text
shmup/
├── lib/
│   ├── shmup/
│   │   └── game/
│   │       ├── game_state.ex      # struct + phase transitions
│   │       ├── physics.ex         # movement, clamping
│   │       ├── collision.ex
│   │       └── simulation.ex      # single tick step
│   └── shmup_web/
│       ├── live/
│       │   └── game_live.ex       # mount, tick, handle_event from hook
│       ├── components/
│       └── endpoint.ex
├── assets/
│   └── js/
│       ├── app.js                 # register Hook
│       └── hooks/
│           └── game_hook.js       # pointer, fire, rAF/throttle, pushEvent
├── test/
│   ├── shmup/game/
│   └── shmup_web/live/
└── .mise.toml                     # erlang + elixir versions (Mise)
```

**Structure Decision**: Single Phoenix app **`shmup/`** at repo root **or** nested under `apps/shmup` only if later umbrella; default **flat** `mix phx.new` output at repository root is acceptable—align `feature.json` / CI paths accordingly.

## Complexity Tracking

> No unjustified constitution violations for this feature.
