---

description: "Task list for 002 shmup difficulty waves"
---

# Tasks: Shmup — Độ khó theo thời gian (002)

**Input**: Design documents from `/specs/002-shmup-difficulty-waves/`  
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/liveview-hook-events.md](./contracts/liveview-hook-events.md)

**Tests**: Không có yêu cầu TDD trong spec — không tạo task test riêng; bước cuối gồm chạy `mix test` và quickstart.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Có thể song song (file khác nhau, không chờ task chưa xong trong cùng file logic)
- **[USn]**: User story trong [spec.md](./spec.md)

## Path Conventions

- Ứng dụng Phoenix: `shmup/` (xem [plan.md](./plan.md))

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Xác nhận môi trường và đường dẫn trùng plan.

- [ ] T001 Verify `shmup/mix.exs` exists and `cd shmup && mix compile` succeeds per `specs/002-shmup-difficulty-waves/quickstart.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Hằng số tier, module tham số độ khó, và trường state chung — **bắt buộc xong trước các user story**.

**⚠️ CRITICAL**: Không triển khai US1–US3 cho đến khi phase này hoàn tất.

- [ ] T002 [P] Create `shmup/lib/shmup/game/difficulty.ex` exporting tier helpers (spawn interval, max enemies, enemy fire period, tier cap, optional HP base) aligned with `specs/002-shmup-difficulty-waves/research.md` (200 ticks = 10s at 20 Hz)
- [ ] T003 [P] Extend `shmup/lib/shmup/game/game_state.ex` with `difficulty_tier` and `play_tick` (defaults in `new_playing/0`)

**Checkpoint**: Foundation ready — user story implementation can begin

---

## Phase 3: User Story 1 — Địch bắn đạn và độ khó tăng theo chu kỳ 10 giây (Priority: P1) 🎯 MVP

**Goal**: `play_tick` chỉ tăng khi `:playing`; mỗi ~10s game-time nâng `difficulty_tier`; spawn/tần suất và bắn địch phụ thuộc tier; snapshot gửi thêm metadata cho HUD/debug.

**Independent Test**: Chơi một vàn: địch bắn; sau mỗi ~10s thấy bậc/tần suất spawn hoặc mật độ tăng (hoặc đọc `difficulty_tier` trong `frame`).

### Implementation for User Story 1

- [ ] T004 [US1] In `shmup/lib/shmup/game/simulation.ex`: increment `play_tick` each `step` while playing; advance `difficulty_tier` on tier boundary (every 200 `play_tick` at current tick rate); replace fixed spawn interval with `Difficulty` + enforce `max_enemies` cap
- [ ] T005 [P] [US1] In `shmup/lib/shmup/game/simulation.ex`: replace fixed enemy fire cadence with tier-based period from `Difficulty` (keep enemy bullets authoritative per existing collision rules)
- [ ] T006 [P] [US1] In `shmup/lib/shmup_web/live/game_live.ex`: add `difficulty_tier` and `play_tick` to `snapshot/1` for `push_event("frame", ...)` per `specs/002-shmup-difficulty-waves/contracts/liveview-hook-events.md`

**Checkpoint**: User Story 1 delivers tiered spawn rate and enemy fire + observable tier in snapshots

---

## Phase 4: User Story 2 — Chuyển động thẳng → cong → phức tạp (Priority: P2)

**Goal**: Tier thấp: quỹ đạo gần đường thẳng; tier cao: thêm dao động/cong hoặc ghép đoạn theo `research.md`.

**Independent Test**: So sánh quỹ đạo địch đầu ván vs sau vài bậc — thấy cong/phức tạp hơn.

### Implementation for User Story 2

- [ ] T007 [US2] In `shmup/lib/shmup/game/physics.ex`: add movement updaters for at least `:straight` and `:sine` (or segmented) modes using `play_tick` / per-enemy parameters from `specs/002-shmup-difficulty-waves/data-model.md`
- [ ] T008 [US2] In `shmup/lib/shmup/game/simulation.ex`: assign movement mode/params when spawning enemies from `difficulty_tier`; route `move_all/1` through `Physics` so position updates match selected mode

**Checkpoint**: User Story 2 complete — movement visibly evolves with tier

---

## Phase 5: User Story 3 — Sức kháng cự (HP) tăng dần (Priority: P3)

**Goal**: Địch có `hp`; tier cao cần nhiều lần trúng hơn; va chạm trừ `hp` và chỉ cộng điểm khi hạ được.

**Independent Test**: Tier thấp: ít hit để chết; tier cao: nhiều hit hơn cho cùng kiểu địch.

### Implementation for User Story 3

- [ ] T009 [US3] In `shmup/lib/shmup/game/simulation.ex`: set each spawned enemy’s `hp` from `Difficulty` / `difficulty_tier` per `specs/002-shmup-difficulty-waves/data-model.md`
- [ ] T010 [US3] In `shmup/lib/shmup/game/collision.ex`: update `resolve_player_bullets_vs_enemies/3` to decrement enemy `hp`, remove enemy and apply score only when `hp <= 0`, and consume bullet on hit (MVP single-hit damage)

**Checkpoint**: User Story 3 complete — resistance scales with tier

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: UX nhẹ, xác nhận regression và quickstart.

- [ ] T011 [P] Optionally render `difficulty_tier` (or elapsed play time) in `shmup/assets/js/hooks/game_hook.js` when `frame` payload includes new fields
- [ ] T012 Run `cd shmup && mix test` and manual validation steps in `specs/002-shmup-difficulty-waves/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1**: No dependencies
- **Phase 2**: Depends on Phase 1 — **blocks** all user stories
- **Phase 3 (US1)**: Depends on Phase 2
- **Phase 4 (US2)**: Depends on Phase 3 (tier + spawn pipeline in place)
- **Phase 5 (US3)**: Depends on Phase 4 (enemy struct carries `hp`/`movement` consistently) — *if HP is added before curved motion, reorder only with care to keep `enemy` map consistent*
- **Phase 6**: Depends on US1–US3 as scoped

### User Story Dependencies

- **US1**: After Foundational — no dependency on US2/US3
- **US2**: After US1 (uses tiered spawn and same enemy list)
- **US3**: After US2 recommended (single enemy shape for spawn + collision); minimum after US1 if `hp` added before movement (adjust task order only if implementation dictates)

### Parallel Opportunities

- **Phase 2**: T002 and T003 different files — parallel
- **US1**: After T004, T005 and T006 parallel (`simulation.ex` vs `game_live.ex` — if two devs, coordinate `simulation.ex` first for T004 alone, then T005∥T006)
- **Polish**: T011 parallel with prep for T012 (T012 should run after code complete)

---

## Parallel Example: User Story 1

After T004 completes:

```text
Task T005: tier-based enemy fire in shmup/lib/shmup/game/simulation.ex
Task T006: snapshot fields in shmup/lib/shmup_web/live/game_live.ex
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Phase 1 + Phase 2  
2. Phase 3 (US1)  
3. **STOP**: Validate spawn/tier/fire + `frame` fields (`quickstart.md`)

### Incremental Delivery

1. US1 → demo  
2. US2 → demo  
3. US3 → demo  
4. Polish

---

## Notes

- Giữ tick ~20 Hz (`GameLive` `@tick_ms`); nếu đổi, cập nhật `tier_period_ticks` trong `Difficulty` cho đúng 10s wall-time trong ván.
- Trần `max_enemies` và tần suất bắn để đáp ứng performance constitution.
