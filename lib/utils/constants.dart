/// Constants
/// Định nghĩa các hằng số được sử dụng trong app
class ApiConstants {
  // API Configuration
  // 🔧 CẤU HÌNH API URL:
  static const String baseUrl = 'https://kltn-l679.onrender.com/api';

  // API Endpoints
  static const String medicinesEndpoint = '/Medicines';
}

class AppConstants {
  // API Configuration
  // 🔧 CẤU HÌNH API URL:
  // API của bạn chạy với HTTPS và có prefix /api

  // ✅ DÙNG HTTPS (API của bạn đang dùng HTTPS)
  // Cho Android Emulator, dùng 10.0.2.2 để trỏ đến localhost của máy host
  static const String baseUrl = 'https://kltn-l679.onrender.com/api';

  // Nếu test trên thiết bị thật hoặc iOS simulator, dùng IP thực:
  // static const String baseUrl = 'https://192.168.1.XXX:7283/api';

  // Nếu test trên web browser:
  // static const String baseUrl = 'https://localhost:7283/api';

  // ⚠️ QUAN TRỌNG: Không có dấu / ở đầu để Dio combine đúng với baseUrl
  static const String loginEndpoint = '/TaiKhoan/Login';
  static const String loginWithGoogleEndpoint = '/TaiKhoan/LoginWithGoogle';
  // Endpoint đăng ký - POST /api/TaiKhoan
  static const String registerEndpoint = '/TaiKhoan';
  // CheckUsername sử dụng query parameter: ?username=xxx
  static const String checkUsernameEndpoint = '/TaiKhoan/CheckUsername';
  static const String customerEndpoint = '/KhachHang';

  // Local Storage Keys
  static const String userKey = 'user';
  static const String customerKey = 'customer';
  static const String rememberMeKey = 'remember_me';
  static const String cartKey = 'cart_items';
  static const String tokenKey = 'jwt_token';

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
