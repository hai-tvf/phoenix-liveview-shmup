# Quickstart: Kiểm tra feature 002 (độ khó theo thời gian)

## Chuẩn bị

```bash
cd shmup
mix deps.get
mix compile
```

Cần Erlang/Elixir (Mise: xem `.mise.toml` ở root repo nếu có).

## Kiểm thử tự động

```bash
cd shmup
mix test
```

Sau khi triển khai: thêm/ chạy test tập trung vào `Shmup.Game` (tier mỗi 200 tick ở 20 Hz, HP địch, spawn theo tier, quỹ đạo sóng ở tier cao).

## Chạy tay

```bash
cd shmup
mix phx.server
```

Mở URL dev (mặc định `http://localhost:4000`), **BẮT ĐẦU**, chơi **ít nhất 20–30 giây**:

- Quan sát **tăng mức độ** (số địch / tần suất) sau mỗi ~10 giây.
- Xác nhận **địch vẫn bắn** và mật độ đạn phù hợp tier.
- Ở đầu ván: địch **gần đường thẳng**; sau vài bậc: có **lệch/cong** rõ hơn.
- Địch **khó hạ hơn** (nhiều phát trúng) ở tier cao — có thể bật HUD `difficulty_tier` trong snapshot nếu đã implement.

## Gỡ lỗi nhanh

- Không thấy tăng tier: kiểm tra `play_tick` chỉ tăng khi `:playing` và chu kỳ 200 tick (hoặc hằng số tương ứng `@tick_ms`).
- Giật lag: giảm `max_enemies` hoặc tăng tối thiểu `enemy_spawn_interval` trong bảng tier.
