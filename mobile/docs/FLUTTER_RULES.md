# Flutter Development Rules & Best Practices

Bộ quy tắc tiêu chuẩn để đảm bảo mã nguồn sạch, hiệu quả và dễ bảo trì.

## 1. Coding Standards & Conventions

### Tên gọi (Naming)
- **Classes:** `PascalCase` (e.g., `HomeScreen`, `UserViewModel`).
- **Variables/Methods:** `camelCase` (e.g., `userName`, `fetchData()`).
- **Files/Folders:** `snake_case` (e.g., `home_screen.dart`, `api_service.dart`).
- **Private members:** Bắt đầu bằng dấu gạch dưới (e.g., `_internalState`).

### Clean Code Rules
- **Rule 1:** Hàm không nên quá 50 dòng. Nếu dài hơn, hãy tách nhỏ.
- **Rule 2:** Class không nên quá 300 dòng.
- **Rule 3:** Luôn sử dụng `const` cho các Widget không thay đổi.
- **Rule 4:** Tránh sử dụng `print()`. Sử dụng `debugPrint()` hoặc `Logger` package.

---

## 2. Architecture & State Management

### Kiến trúc (Architecture)
Chúng ta tuân thủ kiến trúc **Layered Architecture**:
- **Data Layer:** API providers, Repositories, Models (DTOs).
- **Domain Layer:** Business logic, Entities, Use Cases.
- **Presentation Layer:** Widgets, State Management (Providers/Blocs/Riverpod).

### State Management
- Không viết Logic trong Widget. Widget chỉ nên dùng để hiển thị.
- Logic phải nằm trong Controllers/ViewModels/Blocs.
- Hạn chế sử dụng `setState` trong các Widget lớn.

---

## 3. UI & Performance

### Tối ưu hóa UI
- **RepaintBoundary:** Sử dụng cho các Widget có animation phức tạp.
- **ListView.builder:** Luôn sử dụng `.builder` cho danh sách dài.
- **Image optimization:** Luôn cung cấp `cacheWidth` hoặc `cacheHeight` khi load ảnh lớn.

### Widget Lifecycle
- Giải phóng tài nguyên (Stream, Controller, Timer) trong hàm `dispose()`.
- Không gọi hàm không đồng bộ (async) trong `build()`.

---

## 4. Linting
Mọi lập trình viên phải tuân thủ các rule trong file `analysis_options.yaml`. Không được ignore các cảnh báo (warnings) trừ trường hợp đặc biệt.
