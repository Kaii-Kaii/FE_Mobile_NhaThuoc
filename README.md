# Nhà Thuốc Medion - Flutter App

Ứng dụng mobile quản lý nhà thuốc Medion được xây dựng bằng Flutter với đầy đủ chức năng đăng nhập, đăng ký và quản lý thông tin khách hàng.

## 🎯 Tính năng

### 🔐 Xác thực
- **Đăng nhập** với tên đăng nhập và mật khẩu
- **Đăng ký** tài khoản mới với validation phức tạp
- **Ghi nhớ đăng nhập** với SharedPreferences
- **Tự động chuyển hướng** dựa trên trạng thái đăng nhập

### 👤 Quản lý thông tin
- **Nhập thông tin khách hàng** sau khi đăng ký thành công
- **Hiển thị thông tin** người dùng và khách hàng
- **Đăng xuất** và xóa dữ liệu local

### 🎨 UI/UX
- Thiết kế hiện đại với gradient background
- Responsive và thân thiện với người dùng
- Loading states và error handling
- Animation mượt mà

## 📁 Cấu trúc Project

```
lib/
├── main.dart                    # Entry point
├── screens/                     # Màn hình
│   ├── auth/
│   │   ├── login_screen.dart           # Màn hình đăng nhập
│   │   ├── register_screen.dart        # Màn hình đăng ký
│   │   └── customer_info_screen.dart   # Màn hình thông tin KH
│   ├── home/
│   │   └── home_screen.dart            # Màn hình chủ
│   └── splash_screen.dart              # Màn hình khởi động
├── services/                    # API Services
│   ├── api_service.dart                # Base API service
│   ├── auth_service.dart               # Auth API
│   └── customer_service.dart           # Customer API
├── models/                      # Data models
│   ├── user_model.dart
│   └── customer_model.dart
├── providers/                   # State management
│   ├── auth_provider.dart
│   └── customer_provider.dart
├── widgets/                     # Reusable widgets
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   └── loading_widget.dart
├── utils/                       # Utilities
│   ├── constants.dart
│   ├── validators.dart
│   └── storage_helper.dart
└── theme/                       # Theme
    └── app_theme.dart
```

## 🚀 Bắt đầu

### Yêu cầu
- Flutter SDK >= 3.7.2
- Dart SDK >= 3.7.2
- Android Studio / VS Code
- Emulator hoặc thiết bị thật

### Cài đặt

1. **Clone repository**
```bash
git clone <repository-url>
cd quan_ly_nha_thuoc
```

2. **Cài đặt dependencies**
```bash
flutter pub get
```

3. **Cấu hình API**

Mở file `lib/utils/constants.dart` và cập nhật API URL:
```dart
static const String baseUrl = 'https://localhost:7283/api';
```

⚠️ **Lưu ý**: App sử dụng self-signed SSL certificate, đã được config bypass trong `api_service.dart`

4. **Chạy app**
```bash
flutter run
```

## 📱 Màn hình

### 1. Màn hình đăng nhập (Login Screen)
- Input: Tên đăng nhập, Mật khẩu
- Toggle hiển thị/ẩn mật khẩu
- Checkbox "Ghi nhớ đăng nhập"
- Link "Quên mật khẩu" (UI only)
- Nút đăng nhập Google, Facebook (UI only)
- Link chuyển đến đăng ký

**API Endpoint**: `POST /api/TaiKhoan/Login`

### 2. Màn hình đăng ký (Register Screen)
- Input: Tên đăng nhập, Email, Mật khẩu, Xác nhận mật khẩu
- Validation phức tạp với hiển thị requirements
- Real-time validation
- Hiển thị lỗi từ API

**API Endpoint**: `POST /api/TaiKhoan/DangKy`

### 3. Màn hình thông tin khách hàng (Customer Info Screen)
- Progress indicator 3 bước
- Input: Họ tên, Ngày sinh, SĐT, Giới tính, Địa chỉ
- DatePicker cho ngày sinh
- Radio buttons cho giới tính
- Modal thành công khi hoàn tất

**API Endpoint**: `POST /api/KhachHang`

### 4. Màn hình chủ (Home Screen)
- Hiển thị thông tin tài khoản
- Hiển thị thông tin khách hàng
- Quick actions (UI only)
- Chức năng đăng xuất

## 🔧 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1           # State management
  dio: ^5.4.0                # HTTP client
  shared_preferences: ^2.2.2 # Local storage
  intl: ^0.18.1              # Date formatting
  font_awesome_flutter: ^10.6.0 # Icons
```

## 🎨 Theme

App sử dụng color scheme như sau:
- **Primary Color**: `#17A2B8` (Cyan)
- **Secondary Color**: `#138496` (Dark Cyan)
- **Error Color**: `#DC3545`
- **Success Color**: `#28A745`
- **Background**: Linear gradient `#E8F5F7` → `#D4EEF2`

## 🔐 Validation Rules

### Tên đăng nhập
- 6-50 ký tự
- Chỉ chữ và số

### Email
- Format email hợp lệ

### Mật khẩu
- Tối thiểu 8 ký tự
- Có chữ hoa (A-Z)
- Có chữ thường (a-z)
- Có số (0-9)
- Có ký tự đặc biệt (@$!%*?&)

### Họ tên
- Tối thiểu 2 từ

### Số điện thoại
- 10-11 số
- Bắt đầu bằng 0

### Ngày sinh
- Tuổi từ 1-150

### Địa chỉ
- Tối thiểu 5 ký tự

## 💾 Local Storage

App lưu trữ các thông tin sau trong SharedPreferences:
- **user**: Thông tin tài khoản (maTK, tenDangNhap, email)
- **customer**: Thông tin khách hàng (maKH, hoTen, dienThoai, ...)
- **remember_me**: Trạng thái "Ghi nhớ đăng nhập"

## 🔄 Auto-redirect Logic

Khi khởi động app:
1. Nếu **chưa đăng nhập** → Login Screen
2. Nếu **đã đăng nhập + chưa có thông tin KH** → Customer Info Screen
3. Nếu **đã đăng nhập + có thông tin KH** → Home Screen

## 📝 API Format

### Login Request
```json
{
  "TenDangNhap": "string",
  "MatKhau": "string"
}
```

### Login Response
```json
{
  "maTK": 1,
  "tenDangNhap": "string",
  "email": "string"
}
```

## 📄 License

This project is private and proprietary.

---

**Note**: Đây là version 1.0 với các chức năng cơ bản. Các chức năng nâng cao sẽ được phát triển trong các phiên bản tiếp theo.
