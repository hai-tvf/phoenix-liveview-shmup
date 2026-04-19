# Implementation Plan: Shmup — Độ khó theo thời gian, đạn địch, quỹ đạo và kháng cự

**Branch**: `002-shmup-difficulty-waves` | **Date**: 2026-04-19 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-shmup-difficulty-waves/spec.md`, extending the existing Phoenix app under `shmup/`.

## Summary

Tăng độ khó theo **chu kỳ 10 giây** thời gian chơi (`:playing`), bằng cách nâng **bậc độ khó (tier)** trên máy chủ trong `Shmup.Game.*`. Mỗi bậc tăng **tần suất spawn / số địch đồng thời** (có **trần** để giữ hiệu năng), làm **đạn địch** nhất quán với luật hiện có và điều chỉnh tần suất theo tier, chuyển **quỹ đạo địch** từ **thẳng** sang **cong** (ví dụ dao động ngang theo thời gian) rồi **phức tạp hơn** (ví dụ ghép đoạn hoặc tham số hóa theo tier), và tăng **kháng cự** qua **`hp`** trên địch (trừ dần khi trúng đạn người chơi). **LiveView** giữ tick hiện tại (~20 Hz, `handle_info :tick`), đẩy snapshot `frame` + tùy chọn metadata tier cho HUD/debug; logic mô phỏng nằm hoàn toàn trong `Simulation`, `Physics`, `Collision`, `GameState`.

## Technical Context

**Language/Version**: Elixir (theo `shmup/mix.exs` và toolchain Mise trong repo).  
**Primary Dependencies**: Phoenix + LiveView; asset pipeline mặc định; **không Ecto** cho vòng chơi.  
**Storage**: Không lưu độ khó trên server; trạng thái ván trong process LiveView.  
**Testing**: ExUnit cho `Shmup.Game.*` (tier, spawn, HP, va chạm); `Phoenix.LiveViewTest` smoke cho start → chơi → game over.  
**Target Platform**: Trình duyệt desktop hiện đại; `mix phx.server` khi dev.  
**Project Type**: Ứng dụng web Phoenix đơn (`shmup/`).  
**Performance Goals**: Giữ tick **~20 Hz** (50 ms) như hiện tại; giới hạn **số địch tối đa** và tần suất bắn để payload `frame` và thời gian bước mô phỏng vẫn ổn định.  
**Constraints**: Một nguồn sự thật trên server; hook chỉ gửi input, không nhân đôi luật game; thời gian tier dựa trên **tick trong `:playing`** (app hiện **không có pause** — nếu sau này thêm pause, đồng bộ định nghĩa “10 giây chơi”).  
**Scale/Scope**: Một phiên LiveView; bảng tham số tier có giới hạn trên (ví dụ tier tối đa hoặc spawn tối thiểu) để tránh không thể chơi và tràn entity.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Aligned with `.specify/memory/constitution.md` (Phoenix LiveView vertical shmup):

- [x] **LiveView-native surface**: `GameLive` lên lịch `:tick`, `Simulation.step/1` là nguồn sự thật; hook `input` như hiện tại; `push_event("frame", …)` mỗi tick khi `:playing`.
- [x] **Pure game core**: Tier, spawn, quỹ đạo, `hp`, đạn địch trong `lib/shmup/game/*.ex` không import LiveView.
- [x] **Testing**: Bảng kiểm thử cho tier mỗi N tick, HP và va chạm; smoke LiveView cho luồng chơi.
- [x] **Performance**: Giữ cadence ~20 Hz; snapshot gọn; trần số địch / tần suất bắn được ghi trong `research.md`.
- [x] **Incremental scope**: Chỉ mở rộng mô phỏng và snapshot; không thêm DB hay multiplayer.

**Post Phase 1**: Thiết kế thỏa constitution; không cần Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/002-shmup-difficulty-waves/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md   # /speckit.tasks — không tạo bởi /speckit.plan
```

### Source Code (repository)

```text
shmup/
├── lib/shmup/game/
│   ├── game_state.ex       # tier, play_tick, enemy fields (hp, movement_mode, …)
│   ├── simulation.ex       # bước tier mỗi 10s game-time, spawn/fire/move theo tier
│   ├── physics.ex          # cập nhật vị trí theo chế độ quỹ đạo
│   ├── collision.ex        # trừ hp địch; loại khi hp <= 0
│   └── difficulty.ex       # (tuỳ chọn) bảng tham số theo tier — hoặc module private trong simulation
├── lib/shmup_web/live/
│   └── game_live.ex        # snapshot có thể thêm tier / time_to_next_tier
├── assets/js/hooks/
│   └── game_hook.js        # vẽ như hiện tại; HUD tier nếu có field mới
└── test/shmup/game/
    └── …                   # tests tier, hp, movement
```

**Structure Decision**: Tiếp tục một app Phoenix **`shmup/`**; mọi thay đổi gameplay trong `Shmup.Game.*` và điều phối trong `GameLive`.

## Complexity Tracking

> Không có vi phạm constitution cần biện minh.
