import 'package:flutter/foundation.dart';
import 'package:quan_ly_nha_thuoc/models/user_model.dart';
import 'package:quan_ly_nha_thuoc/services/auth_service.dart';
import 'package:quan_ly_nha_thuoc/utils/constants.dart';
import 'package:quan_ly_nha_thuoc/utils/storage_helper.dart';

/// Auth Provider
/// Provider quản lý state đăng nhập/đăng ký
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;
  bool get isLoggedIn => _user != null;

  /// Initialize - Load user data từ local storage
  Future<void> init() async {
    try {
      // Load remember me preference
      _rememberMe = StorageHelper.getBool(AppConstants.rememberMeKey) ?? false;

      // Load user data nếu remember me được bật
      if (_rememberMe) {
        await loadUser();
      }
    } catch (e) {
      debugPrint('Error initializing auth provider: $e');
    }
  }

  /// Load user data từ local storage
  Future<void> loadUser() async {
    try {
      final userData = StorageHelper.getObject(AppConstants.userKey);
      if (userData != null) {
        _user = UserModel.fromJson(userData);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  /// Set remember me
  void setRememberMe(bool value) {
    _rememberMe = value;
    StorageHelper.setBool(AppConstants.rememberMeKey, value);
    notifyListeners();
  }

  /// Đăng nhập
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Call API
      final user = await _authService.login(
        username: username,
        password: password,
      );

      // Save user data
      _user = user;
      await StorageHelper.setObject(AppConstants.userKey, user.toJson());

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    }
  }

  /// Đăng ký
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Call API
      await _authService.register(
        username: username,
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    try {
      _user = null;

      // Xóa user data từ local storage
      await StorageHelper.remove(AppConstants.userKey);
      await StorageHelper.remove(AppConstants.customerKey);

      // Giữ lại remember me preference
      // Không xóa AppConstants.rememberMeKey

      notifyListeners();
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
