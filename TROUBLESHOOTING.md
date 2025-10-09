# 🔧 Hướng dẫn khắc phục lỗi kết nối API

## ✅ Đã fix tự động

### 1. Thêm quyền Internet vào AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 2. Cho phép HTTP traffic (không chỉ HTTPS)
```xml
android:usesCleartextTraffic="true"
```

### 3. Cập nhật API URL cho Android Emulator
```dart
static const String baseUrl = 'http://10.0.2.2:7283/api';
```

---

## 📋 Checklist để kết nối thành công

### Bước 1: Đảm bảo API Server đang chạy
```bash
# Kiểm tra API có chạy không
# Mở browser và truy cập: http://localhost:7283/api
```

### Bước 2: Chọn đúng URL theo môi trường

Mở file `lib/utils/constants.dart` và chọn URL phù hợp:

#### 🤖 Android Emulator
```dart
static const String baseUrl = 'http://10.0.2.2:7283/api';
```
- `10.0.2.2` là địa chỉ đặc biệt của Android Emulator trỏ về `localhost` của máy host

#### 📱 iOS Simulator
```dart
static const String baseUrl = 'http://localhost:7283/api';
// hoặc
static const String baseUrl = 'http://127.0.0.1:7283/api';
```

#### 📲 Thiết bị thật (Android/iOS)
```dart
static const String baseUrl = 'http://192.168.1.100:7283/api';
```
- Thay `192.168.1.100` bằng **IP address của máy tính** đang chạy API server
- Đảm bảo máy tính và thiết bị **cùng mạng WiFi**

#### ☁️ API trên Server/Cloud
```dart
static const String baseUrl = 'https://your-api-domain.com/api';
```

---

## 🔍 Cách tìm IP address của máy tính

### Windows
```bash
ipconfig
```
Tìm dòng `IPv4 Address` trong phần `Wireless LAN adapter Wi-Fi`

### macOS/Linux
```bash
ifconfig
# hoặc
ip addr show
```

---

## 🧪 Test kết nối API

### Test 1: Từ trình duyệt
```
http://localhost:7283/api/TaiKhoan/Login
```
Nếu thấy response hoặc lỗi 405 (Method Not Allowed) → API đang chạy ✅

### Test 2: Từ Postman/Thunder Client
```
POST http://localhost:7283/api/TaiKhoan/Login
Body:
{
  "TenDangNhap": "test",
  "MatKhau": "test123"
}
```

### Test 3: Kiểm tra logs trong Flutter
Xem console khi chạy app, sẽ thấy:
```
🚀 REQUEST[POST] => PATH: /TaiKhoan/Login
📦 DATA: {TenDangNhap: test, MatKhau: xxx}
```

---

## ⚠️ Các lỗi thường gặp

### Lỗi 1: "Connection refused" hoặc "Connection timeout"
**Nguyên nhân**: Không kết nối được đến server

**Giải pháp**:
1. Kiểm tra API server có đang chạy không
2. Kiểm tra URL có đúng không
3. Kiểm tra Firewall có chặn port 7283 không
4. Với thiết bị thật: Đảm bảo cùng mạng WiFi

### Lỗi 2: "SocketException: OS Error: Connection timed out"
**Nguyên nhân**: Timeout khi kết nối

**Giải pháp**:
```dart
// Tăng timeout trong api_service.dart
connectTimeout: const Duration(seconds: 60),
receiveTimeout: const Duration(seconds: 60),
```

### Lỗi 3: "HandshakeException" hoặc "Certificate verify failed"
**Nguyên nhân**: Lỗi SSL certificate

**Giải pháp**:
1. Dùng HTTP thay vì HTTPS (cho development)
2. Hoặc đảm bảo SSL bypass đã được config trong `api_service.dart`

### Lỗi 4: "Cleartext HTTP traffic not permitted"
**Nguyên nhân**: Android không cho phép HTTP traffic

**Giải pháp**: Đã fix bằng cách thêm `android:usesCleartextTraffic="true"`

---

## 🎯 Các bước khắc phục theo thứ tự

### Bước 1: Clean và rebuild app
```bash
flutter clean
flutter pub get
flutter run
```

### Bước 2: Kiểm tra API server
- Mở browser: `http://localhost:7283/api`
- Hoặc test endpoint: `http://localhost:7283/api/TaiKhoan/Login`

### Bước 3: Cập nhật URL trong constants.dart
```dart
// Android Emulator
static const String baseUrl = 'http://10.0.2.2:7283/api';

// Thiết bị thật
static const String baseUrl = 'http://192.168.1.XXX:7283/api';
```

### Bước 4: Kiểm tra AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.INTERNET" />
android:usesCleartextTraffic="true"
```

### Bước 5: Hot restart app (không phải hot reload)
```
Press R in terminal
hoặc
Stop và run lại app
```

---

## 📱 Config cho từng môi trường

Để dễ dàng chuyển đổi giữa các môi trường, bạn có thể tạo file config:

```dart
// lib/config/environment.dart
class Environment {
  static const bool isProduction = false;
  
  static String get apiUrl {
    if (isProduction) {
      return 'https://api.medion.com/api';
    }
    
    // Development
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:7283/api'; // Emulator
      // return 'http://192.168.1.100:7283/api'; // Real device
    } else {
      return 'http://localhost:7283/api'; // iOS Simulator
    }
  }
}
```

Sau đó sử dụng trong constants.dart:
```dart
static final String baseUrl = Environment.apiUrl;
```

---

## 🆘 Vẫn không được?

### Debug mode
Thêm debug prints trong `api_service.dart`:

```dart
onError: (error, handler) {
  print('❌ ERROR TYPE: ${error.type}');
  print('❌ ERROR MESSAGE: ${error.message}');
  print('❌ ERROR RESPONSE: ${error.response?.data}');
  print('❌ ERROR STACKTRACE: ${error.stackTrace}');
  return handler.next(error);
},
```

### Kiểm tra console logs
Khi gọi API, xem console sẽ thấy:
```
🚀 REQUEST[POST] => PATH: /TaiKhoan/Login
📦 DATA: {...}
✅ RESPONSE[200] => DATA: {...}  // Thành công
❌ ERROR[xxx] => MESSAGE: ...     // Lỗi
```

---

## 📞 Contact

Nếu vẫn gặp vấn đề, cung cấp thông tin:
1. Loại thiết bị (Android Emulator/iOS Simulator/Real device)
2. Error message đầy đủ từ console
3. API URL đang sử dụng
4. Kết quả test API từ browser/Postman
