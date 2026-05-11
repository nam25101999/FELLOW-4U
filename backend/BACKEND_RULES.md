# Spring Boot Development Rules & Standards

Chào mừng bạn đến với phần phát triển Backend cho dự án Fellow4U. Để đảm bảo mã nguồn sạch, dễ bảo trì và mở rộng, chúng ta sẽ tuân thủ các quy tắc sau:

## 1. Kiến trúc (Architecture)
Chúng ta sử dụng kiến trúc **Layered Architecture** (Kiến trúc phân lớp):
- **Controller Layer**: Tiếp nhận Request, điều hướng và phản hồi kết quả (REST API). Không chứa logic nghiệp vụ.
- **Service Layer**: Nơi xử lý logic nghiệp vụ chính (Business Logic).
- **Repository Layer**: Tương tác với cơ sở dữ liệu (Spring Data JPA).
- **Entity Layer**: Định nghĩa các đối tượng ánh xạ với Database.
- **DTO (Data Transfer Object)**: Sử dụng để trao đổi dữ liệu giữa Client và Server, tránh lộ cấu trúc Database.

## 2. Quy tắc đặt tên (Naming Conventions)
- **Package**: Viết thường toàn bộ (ví dụ: `com.fellow4u.backend.controller`).
- **Class**: PascalCase (ví dụ: `UserService`, `AuthController`).
- **Method/Variable**: camelCase (ví dụ: `getUserById`, `isVerified`).
- **Interface**: PascalCase (không thêm tiền tố `I`).
- **Implementation**: Tên Interface + `Impl` (ví dụ: `UserServiceImpl`).

## 3. REST API Standards
- Sử dụng đúng các HTTP Methods:
  - `GET`: Lấy dữ liệu.
  - `POST`: Tạo mới dữ liệu.
  - `PUT`: Cập nhật toàn bộ dữ liệu.
  - `PATCH`: Cập nhật một phần dữ liệu.
  - `DELETE`: Xóa dữ liệu.
- Định dạng phản hồi chung (Common Response Structure):
  ```json
  {
    "status": "success/error",
    "message": "Thông báo",
    "data": { ... }
  }
  ```

## 4. Xử lý ngoại lệ (Exception Handling)
- Sử dụng `@RestControllerAdvice` và `@ExceptionHandler` để quản lý lỗi tập trung.
- Trả về mã lỗi HTTP phù hợp (400, 401, 403, 404, 500).

## 5. Bảo mật (Security)
- Sử dụng **Spring Security** kết hợp với **JWT (JSON Web Token)** cho đăng ký/đăng nhập.
- Không lưu mật khẩu thô vào Database (Sử dụng `BCryptPasswordEncoder`).

## 6. Coding Best Practices
- Sử dụng **Lombok** (`@Data`, `@Builder`, `@NoArgsConstructor`, ...) để giảm thiểu mã thừa.
- Luôn sử dụng `@Autowired` thông qua **Constructor Injection** (tốt nhất là dùng `@RequiredArgsConstructor` của Lombok).
- Validate dữ liệu đầu vào bằng `@Valid` và các annotation như `@NotBlank`, `@Email`, ...

---
*Lưu ý: Luôn chạy `mvn clean install` trước khi commit mã nguồn để đảm bảo không có lỗi build.*
