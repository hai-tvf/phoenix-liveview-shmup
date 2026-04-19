# Phase 0 Research: Độ khó theo thời gian (002)

## 1. Đồng hồ “10 giây” trong ván chơi

**Decision**: Dùng **số tick đã trôi qua trong `phase == :playing`** sau khi `start`. Với tick **20 Hz** (chu kỳ 50 ms), **10 giây** = **200 tick**. Mỗi lần `Simulation.step/1` chạy khi đang chơi, tăng `play_tick` (hoặc tương đương); khi `rem(play_tick, 200) == 0` và `play_tick > 0`, tăng `difficulty_tier` (hoặc khi `play_tick` vượt ngưỡng `tier * 200`).

**Rationale**: Khớp spec (“thời gian trong ván đang chơi”); không phụ thuộc đồng hồ tường; dễ kiểm thử xác định trong ExUnit.

**Alternatives considered**:

- **Thời gian thực (`System.monotonic_time`)**: chính xác wall-clock hơn nhưng khó tái lập trong test và lệch với bước rời rạc của game.
- **Chỉ dùng `tick` toàn session**: bị lẫn splash/game over — tách `play_tick` rõ ràng hơn.

---

## 2. Tiến trình độ khó trên mỗi tier

**Decision**: Bảng tham số theo `difficulty_tier` (số nguyên không âm, có **trần**):

- **`enemy_spawn_interval`**: giảm theo tier (spawn thường xuyên hơn), tới **ngưỡng tối thiểu** (ví dụ không dưới 15 tick) để tránh flood.
- **`max_enemies`**: tăng theo tier có **trần** (ví dụ 25–40) để đảm bảo SC về hiệu năng cảm nhận.
- **`enemy_fire`**: chu kỳ bắn địch phụ thuộc tier (ví dụ `rem(play_tick, fire_period(tier))` với `fire_period` giảm khi tier tăng), vẫn giới hạn tối thiểu khoảng cách giữa các lần bắn.

**Rationale**: Đáp ứng FR-003 (số lượng/tần suất) và FR-001 (đạn địch) có thể đo trong test.

**Alternatives considered**:

- Chỉ tăng HP không tăng spawn — không đủ theo spec (phải có cả lượng/hành vi/kháng cự).

---

## 3. Quỹ đạo: thẳng → cong → phức tạp

**Decision**:

- **Tier thấp**: `vx = 0`, `vy` hằng (rơi thẳng), giữ tương thích với spawn hiện tại.
- **Tier trung bình**: thêm **dao động ngang** xác định — ví dụ `vx = A(tier) * :math.sin(play_tick * freq + phase0)` với `phase0` từ `id` hoặc vị trí spawn để đa dạng.
- **Tier cao**: **ghép** thẳng + sóng hoặc **đổi đoạn** theo `segment` trên địch (ví dụ mỗi K tick đổi tham sóng / hướng), vẫn là hàm thuần tuý của `tick` và trạng thái enemy để dễ test.

**Rationale**: Đạt “cong” và “phức tạp hơn” mà không cần engine vật lý nặng; toàn bộ trong `Physics`/`Simulation`.

**Alternatives considered**:

- Đường Bezier với mẫu ngẫu nhiên — khó kiểm thử và tái lập; giữ cho sau nếu cần.

---

## 4. Kháng cự địch (HP)

**Decision**: Mỗi địch có `hp` (số nguyên dương). Đạn người chơi trúng **trừ 1** (hoặc sát thương cố định 1); khi `hp <= 0` mới loại và cộng điểm. Tier cao → `hp` cơ sở cao hơn (ví dụ `1 + div(tier, 2)` có trần).

**Rationale**: Khớp spec và `Collision` hiện tại (một phát loại) cần nâng cấp thành nhiều phát.

**Alternatives considered**:

- “Ẩn” HP chỉ bằng điểm — không đủ để kiểm chứng “số lần trúng” trong SC-003.

---

## 5. Snapshot `frame` và HUD

**Decision**: Thêm tùy chọn vào payload JSON: `difficulty_tier`, có thể thêm `play_seconds` làm số nguyên hoặc bộ đếm ngược tới tier tiếp theo — phục vụ kiểm thử thủ công và SC-001/SC-002.

**Rationale**: Constitution vẫn cho phép assigns/snapshot nhỏ; hook có thể bỏ qua field mới nếu chưa vẽ HUD.

---

## 6. Pause (edge case trong spec)

**Decision (MVP)**: Ứng dụng hiện **không pause**; `play_tick` chỉ tăng khi `:playing`. Nếu sau này thêm pause, spec nên sửa: chỉ tăng `play_tick` khi không pause (hoặc đứng thời gian game).

**Rationale**: Tránh phạm vi không được triển khai trong 002.
