import 'package:quan_ly_nha_thuoc/models/user_model.dart';
import 'package:quan_ly_nha_thuoc/services/api_service.dart';
import 'package:quan_ly_nha_thuoc/utils/constants.dart';

/// Auth Service
/// Service xử lý đăng nhập và đăng ký
class AuthService {
  final ApiService _apiService = ApiService();

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
      await _apiService.post(
        AppConstants.registerEndpoint,
        data: {'TenDangNhap': username, 'Email': email, 'MatKhau': password},
      );

      return true;
    } catch (e) {
      throw Exception(ApiService.handleError(e));
    }
  }
}
