/// Constants
/// Định nghĩa các hằng số được sử dụng trong app
class ApiConstants {
  // API Configuration
  // 🔧 CẤU HÌNH API URL:
  static const String baseUrl = 'https://10.0.2.2:7283/api';

  // API Endpoints
  static const String medicinesEndpoint = '/Medicines';
}

class AppConstants {
  // API Configuration
  // 🔧 CẤU HÌNH API URL:
  // API của bạn chạy với HTTPS và có prefix /api

  // ✅ DÙNG HTTPS (API của bạn đang dùng HTTPS)
  static const String baseUrl = 'https://10.0.2.2:7283/api';

  // Nếu HTTPS không work, thử HTTP:
  // static const String baseUrl = 'http://10.0.2.2:7283/api';

  // Hoặc dùng IP thực của máy tính (tìm bằng ipconfig):
  // static const String baseUrl = 'https://192.168.1.XXX:7283/api';

  // ⚠️ QUAN TRỌNG: Không có dấu / ở đầu để Dio combine đúng với baseUrl
  // ⚠️ Cả Login và Register đều dùng endpoint /TaiKhoan/Login
  static const String loginEndpoint = '/TaiKhoan/Login';
  static const String registerEndpoint =
      '/TaiKhoan/ConfirmEmail'; // ✅ Dùng chung với Login
  static const String customerEndpoint = '/KhachHang';

  // Local Storage Keys
  static const String userKey = 'user';
  static const String customerKey = 'customer';
  static const String rememberMeKey = 'remember_me';
  static const String cartKey = 'cart_items';

  // Validation
  static const int minUsernameLength = 6;
  static const int maxUsernameLength = 50;
  static const int minPasswordLength = 8;
  static const int minNameWords = 2;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 11;
  static const int minAge = 1;
  static const int maxAge = 150;
  static const int minAddressLength = 5;

  // Regular Expressions
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String usernamePattern = r'^[a-zA-Z0-9]+$';
  static const String passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]';
  static const String phonePattern = r'^0\d{9,10}$';

  // Error Messages
  static const String networkError = 'Lỗi kết nối mạng. Vui lòng kiểm tra lại.';
  static const String serverError = 'Lỗi server. Vui lòng thử lại sau.';
  static const String unknownError = 'Có lỗi xảy ra. Vui lòng thử lại.';

  // Success Messages
  static const String loginSuccess = 'Đăng nhập thành công!';
  static const String registerSuccess = 'Đăng ký thành công!';
  static const String customerInfoSuccess = 'Cập nhật thông tin thành công!';

  // Route Names
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String customerInfoRoute = '/customer-info';
  static const String homeRoute = '/home';
  static const String accountRoute = '/account';
}
