import 'package:quan_ly_nha_thuoc/models/user_model.dart';
import 'package:quan_ly_nha_thuoc/services/api_service.dart';
import 'package:quan_ly_nha_thuoc/services/google_auth_service.dart';
import 'package:quan_ly_nha_thuoc/utils/constants.dart';

/// Auth Service
/// Service xử lý đăng nhập và đăng ký
class AuthService {
  final ApiService _apiService = ApiService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  /// Đăng nhập
  ///
  /// [username] - Tên đăng nhập
  /// [password] - Mật khẩu
  ///
  /// Returns [UserModel] nếu thành công
  /// Throws [Exception] nếu thất bại
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.loginEndpoint,
        data: {'TenDangNhap': username, 'MatKhau': password},
      );

      // Parse response thành UserModel
      final userData = response.data as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      throw Exception(ApiService.handleError(e));
    }
  }

  /// Đăng nhập bằng Google
  ///
  /// Returns [UserModel] nếu thành công
  /// Throws [Exception] nếu thất bại
  Future<UserModel> loginWithGoogle() async {
    try {
      // Step 1: Sign in with Google and get Firebase ID Token
      final googleData = await _googleAuthService.signInWithGoogle();

      if (googleData == null) {
        throw Exception('Đăng nhập bị hủy');
      }

      // Step 2: Send ID Token to backend
      final response = await _apiService.post(
        AppConstants.loginWithGoogleEndpoint,
        data: {
          'idToken': googleData['idToken'],
          'email': googleData['email'],
          'displayName': googleData['displayName'],
          'photoURL': googleData['photoURL'],
        },
      );

      // Parse response thành UserModel
      final userData = response.data as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      // Sign out from Google if backend fails
      await _googleAuthService.signOut();
      throw Exception(ApiService.handleError(e));
    }
  }

  /// Đăng xuất khỏi Google
  Future<void> signOutGoogle() async {
    try {
      await _googleAuthService.signOut();
    } catch (e) {
      print('Error signing out from Google: $e');
    }
  }

  /// Đăng ký tài khoản mới
  ///
  /// [username] - Tên đăng nhập
  /// [email] - Email
  /// [password] - Mật khẩu
  ///
  /// Returns [bool] true nếu thành công
  /// Throws [Exception] nếu thất bại
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Data gửi lên backend - KHÔNG có MaKH
      final registerData = {
        'tenDangNhap': username,
        'email': email,
        'matKhau': password,
      };

      print('📤 Registering with data: $registerData');

      await _apiService.post(AppConstants.registerEndpoint, data: registerData);

      return true;
    } catch (e) {
      print('❌ Register error: $e');
      throw Exception(ApiService.handleError(e));
    }
  }

  /// Kiểm tra tên đăng nhập đã tồn tại chưa
  ///
  /// [username] - Tên đăng nhập cần kiểm tra
  ///
  /// Returns [bool] true nếu đã tồn tại, false nếu chưa
  /// Throws [Exception] nếu thất bại
  Future<bool> checkUsernameExists(String username) async {
    try {
      // Thử cách 1: Query parameter
      final response = await _apiService.get(
        AppConstants.checkUsernameEndpoint,
        queryParameters: {'username': username},
      );

      // API trả về { "Exists": true/false }
      if (response.data is Map<String, dynamic>) {
        return response.data['Exists'] ?? response.data['exists'] ?? false;
      } else if (response.data is bool) {
        return response.data;
      }

      return false;
    } catch (e) {
      // Nếu lỗi 404, có thể endpoint không hỗ trợ
      // Tạm thời return false để không block UI
      print('Error checking username: $e');
      rethrow;
    }
  }
}
