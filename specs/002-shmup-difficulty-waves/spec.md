# Feature Specification: Shmup — Tăng độ khó theo thời gian và kẻ thù

**Feature Branch**: `002-shmup-difficulty-waves`  
**Created**: 2026-04-19  
**Status**: Draft  
**Input**: User description: "Hãy tăng độ khó của trò chơi. Cho máy bay địch bắn đạn. Tăng số lượng và hành vi của kẻ thù sau mỗi 10 giây. Ban đầu, chuyển động của chúng nên theo đường thẳng, nhưng dần dần trở nên cong và phức tạp hơn. Đồng thời, tăng dần sức kháng cự của kẻ thù."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Địch bắn đạn và độ khó tăng theo chu kỳ 10 giây (Priority: P1)

Trong một ván chơi, máy bay địch bắn đạn về phía người chơi (theo quy tắc va chạm đã có của trò). Cứ mỗi **10 giây** thời gian chơi liên tục (tính từ lúc vào màn chơi hoặc từ mốc thời gian được định nghĩa nhất quán trong sản phẩm), độ khó **tăng một bậc**: số lượng địch xuất hiện và/hoặc tần suất xuất hiện tăng so với bậc trước, khiến màn chơi căng thẳng hơn theo thời gian.

**Why this priority**: Không có lớp điều chỉnh độ khó theo thời gian thì yêu cầu “tăng độ khó” không thể kiểm chứng; đạn địch là rủi ro cốt lõi của shmup.

**Independent Test**: Chơi một vàn, xác nhận địch bắn; dùng đồng hồ hoặc chỉ báo thời gian trong trò (nếu có) để xác minh sau mỗi chu kỳ 10 giây có bước tăng rõ ràng về số lượng/tần suất so với giai đoạn trước.

**Acceptance Scenarios**:

1. **Given** ván đang diễn ra, **When** địch xuất hiện, **Then** địch có hành vi bắn đạn về phía người chơi (theo luật trúng/thua hiện có).
2. **Given** ván đang diễn ra, **When** trôi qua mỗi khoảng **10 giây** theo quy ước thời gian của trò, **Then** một bậc khó mới được áp dụng với **nhiều địch hơn và/hoặc xuất hiện dày hơn** so với bậc ngay trước đó (có thể đo được hoặc quan sát được trong kiểm thử).

---

### User Story 2 — Hành vi chuyển động: từ thẳng đến cong và phức tạp (Priority: P2)

Ở các bậc đầu, địch chủ yếu di chuyển theo **đường thẳng** (dễ đoán). Khi độ khó tăng theo thời gian, chuyển động **dần có đoạn cong** và sau đó **phức tạp hơn** (ví dụ kết hợp nhiều đoạn hoặc biến đổi hướng theo quy tắc rõ ràng), sao cho người chơi phải thích nghi chứ không chỉ giữ nguyên một mẫu né cố định.

**Why this priority**: Tách riêng “hình học chuyển động” khỏi chỉ tăng số lượng giúp đúng với mô tả sản phẩm và có thể kiểm thử theo từng bậc.

**Independent Test**: Quan sát hoặc ghi lại quỹ đạo địch ở bậc đầu so với bậc sau; xác nhận có sự chuyển dịch từ chuyển động thẳng đơn giản sang mẫu cong/phức tạp hơn theo tiến trình độ khó.

**Acceptance Scenarios**:

1. **Given** giai đoạn đầu của ván, **When** địch di chuyển, **Then** quỹ đạo phù hợp với **chuyển động thẳng** (theo định nghĩa kiểm thử đã thống nhất).
2. **Given** các bậc khó cao hơn sau nhiều chu kỳ, **When** địch di chuyển, **Then** xuất hiện **đoạn cong** và/hoặc **mẫu phức tạp hơn** so với giai đoạn đầu, phù hợp với bảng tiến trình độ khó.

---

### User Story 3 — Sức kháng cự của địch tăng dần (Priority: P3)

Khi độ khó tăng, địch **chịu được nhiều “đòn” hơn** trước khi bị loại (ví dụ cần nhiều lần trúng đạn người chơi hơn so với trước), để phản ánh “sức kháng cự” tăng dần song song với số lượng và hành vi.

**Why this priority**: Hoàn thiện trục “khó hơn” theo ba chiều: lượng, hành vi, độ bền — phù hợp mô tả người dùng.

**Independent Test**: Ở bậc đầu, một địch tiêu diệt sau một số lần trúng cơ bản; ở bậc sau, địch tương đương cần **nhiều lần trúng hơn** (hoặc tương đương được mô tả trong luật điểm) trước khi biến mất.

**Acceptance Scenarios**:

1. **Given** bậc khó thấp, **When** đạn người chơi trúng địch, **Then** số lần trúng cần thiết để tiêu diệt nằm trong ngưỡng “cơ bản” đã định nghĩa.
2. **Given** bậc khó cao hơn sau nhiều chu kỳ, **When** đạn người chơi trúng địch, **Then** cần **nhiều lần trúng hơn** (hoặc chỉ số kháng cự tương đương) so với bậc thấp để tiêu diệt cùng loại địch (hoặc địch tương đương theo thiết kế).

---

### Edge Cases

- **Thời gian tạm dừng**: Nếu trò có tạm dừng, chu kỳ 10 giây có **đếm thời gian chơi thực** hay **bao gồm cả lúc dừng** — cần một quy tắc nhất quán và ghi trong giả định / kiểm thử.
- **Người chơi thua sớm**: Nếu ván kết thúc trước khi đạt các bậc cao, vẫn phải thấy được ít nhất **một lần** tăng bậc nếu thời gian sống đủ dài (hoặc chế độ thử nghiệm cho phép tua nhanh thời gian).
- **Giới hạn trên**: Có thể cần **trần** độ khó để trò không trở nên không thể hoàn thành — ghi rõ nếu áp dụng.
- **Hiệu năng cảm nhận**: Khi số địch tăng mạnh, trải nghiệm vẫn phải **chơi được** (không chỉ đúng logic mà còn khả năng phản hồi chấp nhận được cho người chơi).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Trò MUST duy trì hoặc hoàn thiện hành vi **địch bắn đạn** về phía người chơi, phù hợp luật thắng/thua hiện có (trúng đạn địch → kết thúc ván hoặc tương đương).
- **FR-002**: Trò MUST tăng độ khó theo **chu kỳ 10 giây** (thời gian chơi liên tục hoặc mốc thời gian được định nghĩa rõ và nhất quán trong tài liệu kiểm thử).
- **FR-003**: Sau mỗi bậc trong chu kỳ trên, trò MUST tăng **số lượng địch và/hoặc tần suất xuất hiện** so với bậc trước (có thể đo hoặc kiểm chứng được).
- **FR-004**: Ở giai đoạn đầu, chuyển động địch MUST chủ yếu theo **đường thẳng**; ở các bậc sau, MUST xuất hiện **chuyển động cong** và **phức tạp hơn** theo tiến trình độ khó (mô tả được trong kịch bản kiểm thử).
- **FR-005**: Theo tiến trình độ khó, địch MUST có **sức kháng cự tăng dần** (ví dụ cần nhiều lần trúng đạn người chơi hơn để tiêu diệt), có thể so sánh giữa bậc thấp và bậc cao.
- **FR-006**: Các thay đổi trên MUST không phá vỡ các luật cốt lõi đã thống nhất trước đó (điều khiển, điểm, lưu kỷ lục cục bộ) trừ khi có quyết định phạm vi riêng được ghi nhận.

### Key Entities

- **Bậc độ khó theo thời gian (difficulty tier)**: Mức hiện tại trong ván; tăng theo chu kỳ 10 giây; ảnh hưởng số lượng/tần suất địch, mẫu chuyển động, và kháng cự.
- **Địch (enemy)**: Thực thể trong ván; có quỹ đạo, khả năng bắn, và chỉ số kháng cự (đòn cần để hạ).
- **Đạn địch**: Va chạm với tàu người chơi theo luật hiện có.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Trong kiểm thử có kiểm soát thời gian, sau ít nhất **hai** chu kỳ 10 giây liên tiếp, người quan sát có thể chỉ ra **hai bậc** khác nhau về **số lượng/tần suất địch** so với đầu ván.
- **SC-002**: Trong cùng kiểm thử, có bằng chứng (quan sát hoặc ghi nhận) rằng chuyển động chuyển từ **chủ yếu thẳng** sang **có thành phần cong/phức tạp hơn** ở bậc sau so với bậc đầu.
- **SC-003**: Ở bậc khó cao hơn, **số lần trúng đạn người chơi cần để tiêu diệt một địch** (hoặc chỉ số tương đương) **lớn hơn** so với bậc dễ cho cùng loại hoặc địch tương đương.
- **SC-004**: Người chơi vẫn có thể **bắt đầu ván mới**, **thấy độ khó tăng dần trong một ván dài**, và **kết thúc ván** theo luật hiện có mà không mất các chức năng cốt lõi (splash, điểm, kỷ lục cục bộ) trừ khi có thay đổi phạm vi được ghi rõ.

## Assumptions

- Tính năng **mở rộng** luồng shmup đã có (màn chơi, điều khiển, điểm, kỷ lục trình duyệt); không yêu cầu máy chủ lưu điểm.
- “10 giây” được hiểu là **thời gian trong ván đang chơi** (không đếm khi đã game over hoặc đang ở màn không chơi), trừ khi sau này đổi trong clarify/plan.
- “Phức tạp hơn” được hiểu là **có thể mô tả và kiểm thử** (không chỉ cảm tính), ví dụ nhiều đoạn quỹ đạo hoặc thay đổi hướng theo quy tắc.
- Sức kháng cự có thể biểu diễn bằng **HP / số lần trúng**; không bắt buộc thanh máu hiển thị nếu phản hồi hình ảnh khác đạt cùng mục tiêu kiểm thử.
