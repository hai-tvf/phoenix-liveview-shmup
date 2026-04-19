# Data Model: Độ khó theo thời gian (002)

Mở rộng mô hình logical trong [001](../001-shmup-start-gameplay/data-model.md). Trạng thái vẫn **authoritative** trên server; JSON snapshot cho hook là **projection**.

## State machine

Không đổi: `:splash` | `:playing` | `:game_over`.

## `GameState` — trường bổ sung

| Field | Type / notes |
|-------|----------------|
| `difficulty_tier` | Số nguyên ≥ 0; bậc độ khó hiện tại. |
| `play_tick` | Số nguyên ≥ 0; chỉ tăng khi `phase == :playing` (mỗi lần `Simulation.step` trong lúc chơi). Dùng cho chu kỳ 10 giây và quỹ đạo phụ thuộc thời gian. |
| Các cooldown spawn/fire | Có thể thay hằng số module bằng hàm của `difficulty_tier` (hoặc đọc từ bảng trong `Difficulty` / private). |

**Quy ước thời gian**: `tier_duration_ticks = 200` khi simulation 20 Hz và 10 giây mỗi bậc (điều chỉnh nếu `@tick_ms` đổi — giữ đồng bộ trong một hằng số duy nhất).

## `Enemy` — cấu trúc mở rộng

| Field | Description |
|-------|-------------|
| `x`, `y`, `w`, `h` | Như hiện tại (hitbox AABB tâm + kích thước). |
| `vx`, `vy` | Vận tốc (có thể cập nhật mỗi tick theo chế độ quỹ đạo). |
| `hp` | Số nguyên > 0; số lần trúng đạn người chơi còn lại trước khi bị loại. |
| `movement` | Atom hoặc map nhỏ mô tả chế độ: ví dụ `:straight`, `{:sine, phase0, amp, freq}`, `{:segmented, …}` — đủ để `Physics`/`Simulation` cập nhật nhất quán. |
| `id` | (Tuỳ chọn) id ổn định để pha sóng; có thể dùng `next_id` lúc spawn. |

## Va chạm đạn người chơi ↔ địch

- Trúng: **trừ `hp`** (mặc định 1 mỗi viên); viên đạn tiêu thụ hoặc xuyên tùy chỉnh — MVP: **một viên một lần trừ**, đạn loại sau va chạm.
- `hp == 0`: loại enemy, cộng điểm như hiện tại (`points_per_kill` có thể scale theo tier — ngoài phạm vi tối thiểu nếu spec không yêu cầu).

## `EnemyBullet`

Không đổi hình học; tần suất sinh do tier và logic `enemy_fire` điều khiển.

## Validation / biên

- `difficulty_tier` có **trần** (`tier_max`) để spawn/HP không tăng vô hạn.
- Số địch trên màn ≤ `max_enemies(tier)` (trần cố định).

## Snapshot JSON (`frame`) — trường gợi ý

| Field | Ghi chú |
|-------|---------|
| `difficulty_tier` | Số nguyên (HUD hoặc debug). |
| `play_tick` hoặc `play_time_sec` | Tuỳ chọn để hiển thị thời gian chơi. |

Hook có thể không dùng các field mới nếu UI chưa có thanh tier.
