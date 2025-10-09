import 'package:quan_ly_nha_thuoc/utils/constants.dart';

/// Validators
/// Các hàm validation cho form input
class Validators {
  /// Validate tên đăng nhập
  /// - 6-50 ký tự
  /// - Chỉ chứa chữ và số
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên đăng nhập';
    }

    if (value.length < AppConstants.minUsernameLength) {
      return 'Tên đăng nhập phải có ít nhất ${AppConstants.minUsernameLength} ký tự';
    }

    if (value.length > AppConstants.maxUsernameLength) {
      return 'Tên đăng nhập không được vượt quá ${AppConstants.maxUsernameLength} ký tự';
    }

    final RegExp usernameRegex = RegExp(AppConstants.usernamePattern);
    if (!usernameRegex.hasMatch(value)) {
      return 'Tên đăng nhập chỉ được chứa chữ cái và số';
    }

    return null;
  }

  /// Validate email
  /// - Format email hợp lệ
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }

    final RegExp emailRegex = RegExp(AppConstants.emailPattern);
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  /// Validate mật khẩu
  /// - Tối thiểu 8 ký tự
  /// - Có chữ hoa, chữ thường, số, ký tự đặc biệt
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Mật khẩu phải có ít nhất ${AppConstants.minPasswordLength} ký tự';
    }

    // Kiểm tra có chữ thường
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Mật khẩu phải có ít nhất một chữ thường';
    }

    // Kiểm tra có chữ hoa
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Mật khẩu phải có ít nhất một chữ hoa';
    }

    // Kiểm tra có số
    if (!value.contains(RegExp(r'\d'))) {
      return 'Mật khẩu phải có ít nhất một chữ số';
    }

    // Kiểm tra có ký tự đặc biệt
    if (!value.contains(RegExp(r'[@$!%*?&]'))) {
      return 'Mật khẩu phải có ít nhất một ký tự đặc biệt (@\$!%*?&)';
    }

    return null;
  }

  /// Validate xác nhận mật khẩu
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }

    if (value != password) {
      return 'Mật khẩu xác nhận không khớp';
    }

    return null;
  }

  /// Validate họ tên
  /// - Tối thiểu 2 từ
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }

    final words = value.trim().split(RegExp(r'\s+'));
    if (words.length < AppConstants.minNameWords) {
      return 'Họ và tên phải có ít nhất ${AppConstants.minNameWords} từ';
    }

    return null;
  }

  /// Validate số điện thoại
  /// - 10-11 số
  /// - Bắt đầu bằng 0
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }

    final RegExp phoneRegex = RegExp(AppConstants.phonePattern);
    if (!phoneRegex.hasMatch(value)) {
      return 'Số điện thoại không hợp lệ (10-11 số, bắt đầu bằng 0)';
    }

    return null;
  }

  /// Validate ngày sinh
  /// - Tuổi từ 1-150
  static String? validateDateOfBirth(DateTime? date) {
    if (date == null) {
      return 'Vui lòng chọn ngày sinh';
    }

    final now = DateTime.now();
    final age = now.year - date.year;

    if (age < AppConstants.minAge || age > AppConstants.maxAge) {
      return 'Tuổi phải từ ${AppConstants.minAge} đến ${AppConstants.maxAge}';
    }

    return null;
  }

  /// Validate địa chỉ
  /// - Tối thiểu 5 ký tự
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập địa chỉ';
    }

    if (value.length < AppConstants.minAddressLength) {
      return 'Địa chỉ phải có ít nhất ${AppConstants.minAddressLength} ký tự';
    }

    return null;
  }
}
