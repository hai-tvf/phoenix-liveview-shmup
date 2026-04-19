---
description: "Task list for Shmup — Start, Mouse Combat, and Local High Score"
---

# Tasks: Shmup — Start, Mouse Combat, and Local High Score

**Input**: Design documents from `/specs/001-shmup-start-gameplay/`  
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [research.md](./research.md), [quickstart.md](./quickstart.md)

**Tests**: Constitution + plan recommend ExUnit for `Shmup.Game.*` and smoke LiveView tests; included as targeted tasks (not full TDD mandate).

**Organization**: Tasks grouped by user story (P1 → P3) after shared setup and foundation.

**Path base**: Phoenix app lives under `shmup/` after `mix phx.new shmup --no-ecto` (adjust if you use another app name).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no ordering dependency)
- **[USn]**: Maps to user stories in [spec.md](./spec.md)

**Path conventions**: `shmup/lib/shmup/`, `shmup/lib/shmup_web/`, `shmup/assets/js/`, `shmup/test/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Mise toolchains, Phoenix scaffold, healthy default build.

- [x] T001 Add `.mise.toml` (and/or `.tool-versions`) at repository root with Erlang + Elixir versions per [quickstart.md](./quickstart.md)
- [x] T002 Generate Phoenix app with `mix phx.new shmup --no-ecto` under `shmup/` (or equivalent integrating into this repo)
- [x] T003 Run `mix deps.get` in `shmup/` and confirm `mix test` and `mix compile` succeed
- [x] T004 [P] Verify `shmup/assets/` esbuild setup and `shmup/assets/js/app.js` entrypoint per `mix phx.new` defaults

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core modules and LiveView shell so all user stories can attach to one game loop.

**⚠️ CRITICAL**: No user story work until this phase completes.

- [x] T005 Define `Shmup.Game.GameState` struct and phase types (`:splash \| :playing \| :game_over`) in `shmup/lib/shmup/game/game_state.ex` per [data-model.md](./data-model.md)
- [x] T006 Implement coordinate **clamp** helpers in `shmup/lib/shmup/game/physics.ex` (match spec FR-002)
- [x] T007 Implement noop / minimal `Shmup.Game.Simulation.step/2` in `shmup/lib/shmup/game/simulation.ex` returning updated `GameState`
- [x] T008 Create `ShmupWeb.GameLive` with `mount/3`, initial assigns, and render for a minimal placeholder in `shmup/lib/shmup_web/live/game_live.ex`
- [x] T009 Wire `/` (or chosen path) to `GameLive` in `shmup/lib/shmup_web/router.ex`

**Checkpoint**: `mix phx.server` loads; LiveView renders without gameplay.

---

## Phase 3: User Story 1 — Khởi động và vào màn chơi (Priority: P1) 🎯 MVP

**Goal**: Màn khởi động với nút **BẮT ĐẦU**; nhấp chuyển sang trạng thái chơi (màn chơi sẵn sàng).

**Independent Test**: Mở `/`, thấy splash và nút; nhấp → phase `:playing` (chưa cần kẻ địch/điểm đầy đủ).

### Implementation for User Story 1

- [x] T010 [US1] Render splash UI with **BẮT ĐẦU** (and layout) in `shmup/lib/shmup_web/live/game_live.ex` and related HEEx under `shmup/lib/shmup_web/`
- [x] T011 [US1] Add `phx-click` (or `handle_event`) for **BẮT ĐẦU** to set phase `:playing`, initialize playfield assigns, and **schedule `:tick`** via `handle_info` in `shmup/lib/shmup_web/live/game_live.ex`

**Checkpoint**: Splash → playing transition works; tick runs while `playing` (simulation may still be minimal).

---

## Phase 4: User Story 2 — Điều khiển chuột, bắn giữ, va chạm và điểm (Priority: P2)

**Goal**: Chuột + giữ để bắn; đạn địch trúng tàu → game over; đạn trúng địch → cộng điểm; clamp pointer; Hook + `pushEvent` / `push_event` per [contracts/liveview-hook-events.md](./contracts/liveview-hook-events.md).

**Independent Test**: Màn chơi: di chuột, giữ bắn, gây va chạm có chủ đích; điểm và game over đúng quy tắc.

### Tests (targeted)

- [x] T012 [P] [US2] Add ExUnit tests for `Shmup.Game.Physics` clamp edge cases in `shmup/test/shmup/game/physics_test.exs`
- [x] T013 [P] [US2] Add ExUnit tests for collision/scoring rules in `shmup/test/shmup/game/collision_test.exs` (or `simulation_test.exs`) depending on module split

### Implementation for User Story 2

- [x] T014 [US2] Extend `GameState` with player, bullets, enemies, enemy bullets, score fields and `Shmup.Game.Collision` in `shmup/lib/shmup/game/collision.ex` per [data-model.md](./data-model.md)
- [x] T015 [US2] Implement full `Simulation.step/2` (movement, spawn, firing, collisions, scoring, game over) in `shmup/lib/shmup/game/simulation.ex`
- [x] T016 [US2] Create `GameHook` in `shmup/assets/js/hooks/game_hook.js` (pointer, throttle/rAF, `pushEvent("input", …)`) and register in `shmup/assets/js/app.js`; attach to playfield container in `game_live.ex` HEEx
- [x] T017 [US2] Handle `input` events in `GameLive`, merge into simulation state with **server-side clamp**, in `shmup/lib/shmup_web/live/game_live.ex`
- [x] T018 [US2] Emit `push_event` `frame`/`phase` each tick with compact payloads per [contracts/liveview-hook-events.md](./contracts/liveview-hook-events.md) in `shmup/lib/shmup_web/live/game_live.ex`
- [x] T019 [US2] Implement client rendering (canvas or SVG) in `shmup/assets/js/hooks/game_hook.js` using `handleEvent` for `frame` / `phase`

**Checkpoint**: Full gameplay loop testable; constitution pure-game vs LiveView boundary respected.

---

## Phase 5: User Story 3 — Lưu điểm cao cục bộ (Priority: P3)

**Goal**: Điểm cao lưu trong trình duyệt; hiển thị khi quay lại (không cần server DB).

**Independent Test**: Chơi một ván, đạt điểm; reload trang — kỷ lục vẫn đúng (cùng `localStorage`).

### Implementation for User Story 3

- [x] T020 [US3] Read/write `localStorage` high score in `shmup/assets/js/hooks/game_hook.js` (namespace key e.g. `shmup:high_score`) per [research.md](./research.md)
- [x] T021 [US3] Display high score on splash and refresh after game over in `shmup/lib/shmup_web/live/game_live.ex` (assigns + hook `phx-update` coordination as needed)

**Checkpoint**: FR-006 satisfied without Ecto.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Smoke tests, docs, alignment with spec post-game flow (plan → splash).

- [x] T022 [P] Add `Phoenix.LiveViewTest` smoke tests for splash → play and game over visibility in `shmup/test/shmup_web/live/game_live_test.exs`
- [x] T023 [P] Run through [quickstart.md](./quickstart.md) on a clean machine and fix gaps; add short `README.md` in `shmup/` or project root pointing to `specs/001-shmup-start-gameplay/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)** → **Phase 2 (Foundational)** → **US1 → US2 → US3** → **Polish**
- **Phase 2** blocks all user stories.

### User Story Dependencies

- **US1** depends on Phase 2 only.
- **US2** depends on US1 (needs `:playing` + tick + LiveView shell).
- **US3** depends on US2 (needs score and game over).

### Parallel Opportunities

- **T012** and **T013** can run in parallel after **T006**/**T014** APIs are stable (or write tests against intended API first).
- **T022** and **T023** can run in parallel after gameplay is complete.

---

## Parallel Example: User Story 2 (tests)

```bash
# After simulation/collision modules exist:
# Task: shmup/test/shmup/game/physics_test.exs
# Task: shmup/test/shmup/game/collision_test.exs
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Complete Phase 1–2  
2. Complete Phase 3 (US1)  
3. **STOP**: validate splash → playing + tick  

### Incremental Delivery

1. US1 → demo  
2. US2 → playable shmup  
3. US3 → persistent high score  
4. Polish → tests + docs  

---

## Notes

- Simulation tick **20–30 Hz** per [plan.md](./plan.md); throttle hook `input` to avoid channel flood.
- Post-game flow per [plan.md](./plan.md): **return to splash** + **BẮT ĐẦU** to replay; align `game_live.ex` transitions accordingly.
- If OTP app name ≠ `Shmup`, rename paths in tasks consistently.
