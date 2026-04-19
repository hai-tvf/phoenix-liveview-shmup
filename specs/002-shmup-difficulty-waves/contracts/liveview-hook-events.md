# Contract: LiveView ↔ JS Hook (Game) — mở rộng 002

Cơ sở: [001 contracts](../../001-shmup-start-gameplay/contracts/liveview-hook-events.md). Mọi sự kiện và tên ổn định ở đó vẫn áp dụng; bên dưới chỉ **phần bổ sung / thay đổi tải**.

## Client → Server (`pushEvent`)

Không đổi bắt buộc cho 002: `input` vẫn là luồng chính. Không thêm sự kiện bắt buộc mới cho tier (độ khó hoàn toàn server-side).

## Server → Client (`push_event`)

### `frame` (khi `playing`)

Payload hiện có (`tick`, `score`, `width`, `height`, `player`, `player_bullets`, `enemy_bullets`, `enemies`) **có thể** mở rộng thêm:

| Field | Type | Khi nào | Ghi chú |
|-------|------|---------|---------|
| `difficulty_tier` | số nguyên | Mỗi tick `:playing` | Bậc độ khó hiện tại (HUD / debug). |
| `play_tick` | số nguyên | Tuỳ chọn | Tick chỉ tính trong `:playing`; hữu ích cho overlay thời gian hoặc QA. |

Mỗi phần tử trong `enemies` (nếu serialize đầy đủ từ server) **có thể** gồm `hp` nếu UI muốn hiển thị thanh máu sau này — **không bắt buộc** cho MVP 002 nếu chỉ đổi logic server.

### `phase`

Không đổi: `splash` | `playing` | `game_over`.

## Tương thích ngược

- Hook cũ: bỏ qua field không biết; vẫn vẽ từ `enemies` / đạn nếu shape vị trí/kích thước giữ nguyên.
- Thay đổi breaking: thêm field mới **không** được làm bắt buộc phía client cho MVP; nếu đổi cấu trúc `enemies`, cập nhật đồng thời `game_hook.js` + test.

## Ordering & performance

- Tần suất `frame` không đổi (~20 Hz).
- Payload lớn hơn nhẹ (vài số nguyên); nếu thêm `hp` mỗi enemy, vẫn trong ngân sách với trần số địch.
