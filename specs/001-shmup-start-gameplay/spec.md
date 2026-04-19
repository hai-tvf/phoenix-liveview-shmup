# Feature Specification: Shmup — Start, Mouse Combat, and Local High Score

**Feature Branch**: `001-shmup-start-gameplay`  
**Created**: 2026-04-19  
**Status**: Draft  
**Input**: User description: "Nhấp vào nút BẮT ĐẦU trên màn hình khởi động sẽ chuyển sang màn hình trò chơi. Người dùng điều khiển tàu của mình bằng chuột, liên tục bắn đạn trong khi giữ chuột. Trò chơi kết thúc nếu đạn của kẻ thù bắn trúng tàu của người chơi. Bắn trúng kẻ thù bằng đạn của người chơi sẽ làm tăng điểm số. Điểm số cuối cùng được lưu vào bộ nhớ trình duyệt. Không cần cơ sở dữ liệu."

## Clarifications

### Session 2026-04-19

- Q: Khi con trỏ chuột ra ngoài vùng chơi, tàu người chơi phải hành xử thế nào? → A: Option C — kẹp (clamp) tọa độ con trỏ vào trong biên vùng chơi; tàu bám theo vị trí con trỏ sau khi kẹp (không để tàu “theo” con trỏ ra ngoài khung).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Khởi động và vào màn chơi (Priority: P1)

Người chơi mở ứng dụng, thấy màn hình khởi động với nút hành động chính (ví dụ "BẮT ĐẦU"). Khi nhấp nút đó, họ được chuyển sang màn hình trò chơi sẵn sàng chơi.

**Why this priority**: Không có bước này thì người chơi không thể vào trải nghiệm cốt lõi.

**Independent Test**: Mở ứng dụng, nhấp nút bắt đầu, quan sát chuyển sang màn chơi (không cần điều khiển tàu để xác nhận giá trị tối thiểu).

**Acceptance Scenarios**:

1. **Given** người chơi đang ở màn khởi động, **When** họ nhấp nút bắt đầu, **Then** giao diện chuyển sang màn trò chơi.
2. **Given** người chơi vừa vào màn chơi, **When** họ quan sát, **Then** tàu người chơi và khu vực chơi hiển thị ở trạng thái sẵn sàng (chưa cần xử lý kẻ thù trong kịch bản này nếu các phần khác đã bật).

---

### User Story 2 - Điều khiển chuột, bắn giữ, va chạm và điểm (Priority: P2)

Người chơi di chuyển tàu theo vị trí con trỏ trong khu vực chơi (con trỏ ra ngoài khung thì dùng vị trí đã kẹp vào trong biên). Khi giữ nút chuột chính (thường là nhấp giữ trái), tàu bắn đạn liên tục. Kẻ thù có thể bắn về phía người chơi. Nếu đạn kẻ thù trúng tàu người chơi, trận kết thúc. Nếu đạn người chơi trúng kẻ thù, điểm số tăng.

**Why this priority**: Đây là vòng lặp chơi cốt lõi của shmup theo mô tả.

**Independent Test**: Vào màn chơi, di chuột, giữ để bắn, gây va chạm có chủ đích với đạn kẻ thù và kẻ thù; xác minh kết thúc trận, tăng điểm khi tiêu diệt kẻ thù.

**Acceptance Scenarios**:

1. **Given** trận đang diễn ra, **When** người chơi di chuyển chuột (kể cả khi con trỏ vượt ra ngoài vùng chơi), **Then** tàu bám theo vị trí con trỏ sau khi đã kẹp vào trong biên vùng chơi (tàu luôn nằm trong khung).
2. **Given** trận đang diễn ra, **When** người chơi giữ nút chuột chính, **Then** đạn người chơi được bắn lặp lại liên tục trong lúc giữ.
3. **Given** trận đang diễn ra, **When** đạn kẻ thù chạm tàu người chơi, **Then** trận kết thúc (trạng thái game over hoặc tương đương).
4. **Given** trận đang diễn ra, **When** đạn người chơi trúng một kẻ thù, **Then** điểm số tăng theo quy tắc điểm đã thống nhất (ví dụ mỗi lần trúng +N điểm).

---

### User Story 3 - Lưu điểm cao cục bộ trên trình duyệt (Priority: P3)

Sau khi chơi, ứng dụng lưu kết quả điểm đáng nhớ (điểm cao nhất đạt được) trong bộ nhớ cục bộ của trình duyệt trên thiết bị đó, để lần sau người chơi vẫn thấy khi quay lại. Không yêu cầu lưu trữ phía máy chủ hay cơ sở dữ liệu.

**Why this priority**: Tăng động lực chơi lại mà không mở rộng phạm vi hạ tầng.

**Independent Test**: Chơi một phiên, đạt một điểm; đóng và mở lại ứng dụng (cùng trình duyệt và nguồn); xác minh điểm cao vẫn hiển thị hoặc được dùng làm tham chiếu theo thiết kế màn hình.

**Acceptance Scenarios**:

1. **Given** người chơi vừa kết thúc một trận với một điểm số, **When** họ quay lại sau (cùng trình duyệt, chưa xóa dữ liệu trang), **Then** điểm cao đã lưu vẫn khả dụng cho trải nghiệm (ví dụ hiển thị trên màn khởi động hoặc sau game over).
2. **Given** không có máy chủ lưu điểm, **When** người chơi sử dụng tính năng, **Then** không yêu cầu đăng nhập hay đồng bộ tài khoản để lưu điểm cục bộ.

---

### Edge Cases

- Con trỏ ra ngoài vùng chơi: áp dụng **kẹp (clamp)** tọa độ con trỏ vào biên vùng chơi rồi đặt tàu theo vị trí đã kẹp (đã làm rõ trong phiên clarify 2026-04-19).
- Người chơi nhấp nhanh nhiều lần thay vì giữ: đạn có thể không bắn liên tục; hành vi phải nhất quán với yêu cầu "giữ để bắn liên tục".
- Lần đầu chơi (chưa có điểm đã lưu): hiển thị hoặc xử lý điểm cao theo cách không gây lỗi (ví dụ 0 hoặc "Chưa có kỷ lục").
- Người chơi xóa dữ liệu trang web: điểm đã lưu mất; ứng dụng không được giả định dữ liệu tồn tại vĩnh viễn.
- Nhiều thẻ hoặc thiết bị: điểm cục bộ không chia sẻ giữa thiết bị — đúng kỳ vọng cho phạm vi này.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Hệ thống MUST hiển thị màn khởi động với nút bắt đầu rõ ràng; nhấp nút MUST chuyển người chơi sang màn trò chơi.
- **FR-002**: Người chơi MUST điều khiển vị trí tàu bằng chuột: tọa độ con trỏ MUST được kẹp vào trong biên vùng chơi (clamp), sau đó tàu MUST bám theo vị trí con trỏ đã kẹp để tàu luôn nằm trong khung chơi.
- **FR-003**: Trong lúc trận đang diễn ra, giữ nút chuột chính MUST duy trì bắn đạn lặp lại liên tục cho đến khi thả.
- **FR-004**: Khi đạn kẻ thù va chạm với tàu người chơi, trận MUST kết thúc.
- **FR-005**: Khi đạn người chơi va chạm với kẻ thù, điểm số MUST tăng theo quy tắc điểm cố định (ví dụ cộng thêm một giá trị cho mỗi lần tiêu diệt).
- **FR-006**: Ứng dụng MUST lưu điểm cao nhất đạt được (hoặc giá trị tương đương được định nghĩa trong giả định) vào bộ nhớ cục bộ của trình duyệt, để dùng lại sau khi tải lại trang trong cùng trình duyệt và nguồn.
- **FR-007**: Phạm vi MUST loại trừ lưu trữ phía máy chủ hoặc cơ sở dữ liệu cho điểm số trong tính năng này.

### Key Entities

- **Phiên chơi (game session)**: Trạng thái từ lúc vào màn chơi đến khi kết thúc; gồm điểm hiện tại, thực thể tàu/đạn/kẻ thù ở mức khái niệm người dùng (vị trí, va chạm).
- **Kỷ lục cục bộ (local high score)**: Một giá trị điểm tốt nhất (hoặc bản ghi đơn) được giữ trên thiết bị qua trình duyệt, không đồng bộ đám mây trong phạm vi này.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Người chơi mới hoàn thành từ màn khởi động đến màn chơi chỉ bằng một hành động nhấp bắt đầu, trong một luồng không nhầm lẫn.
- **SC-002**: Trong thử nghiệm có kiểm soát, 100% lần va chạm "đạn kẻ thù–tàu" được cố ý gây ra đều dẫn đến kết thúc trận; 100% lần tiêu diệt kẻ thù bằng đạn người chơi đều làm điểm tăng đúng quy tắc.
- **SC-003**: Sau khi đạt một điểm và tải lại ứng dụng (cùng trình duyệt, không xóa dữ liệu trang), điểm cao đã lưu vẫn được hiển thị hoặc dùng đúng như thiết kế trong ít nhất ba chu kỳ thử lại liên tiếp.
- **SC-004**: Không có bước bắt buộc nào yêu cầu người chơi tạo tài khoản hoặc kết nối máy chủ chỉ để lưu điểm cục bộ.

## Assumptions

- Người chơi dùng thiết bị có chuột (hoặc đầu vào tương đương nút giữ + con trỏ); điều khiển cảm ứng-only không nằm trong phạm vi trừ khi được mở rộng sau.
- "Điểm số cuối cùng được lưu" được hiểu là lưu **điểm cao nhất** (best) trên trình duyệt để khuyến khích chơi lại; không yêu cầu lưu lịch sử từng ván trừ khi thay đổi phạm vi.
- Kẻ thù và đạn kẻ thù xuất hiện đủ để trò chơi có thể kết thúc do trúng đạn; chi tiết lượng sóng và độ khó do giai đoạn thiết kế/implementation quyết định trong giới hạn hợp lý.
- Một trình duyệt, một nguồn (origin): không yêu cầu đồng bộ điểm giữa các miền hoặc ứng dụng khác.
