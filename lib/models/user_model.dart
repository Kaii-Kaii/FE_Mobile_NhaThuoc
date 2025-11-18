/// User Model
/// Model cho thông tin tài khoản người dùng
class UserModel {
  final String maTK;
  final String tenDangNhap;
  final String email;
  final String? maKhachHang;

  UserModel({
    required this.maTK,
    required this.tenDangNhap,
    required this.email,
    this.maKhachHang,
  });

  /// Convert từ JSON sang UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    String parseAccountId() {
      final possibleKeys = ['maTK', 'MaTK', 'matk'];
      for (final key in possibleKeys) {
        if (json.containsKey(key) && json[key] != null) {
          final value = json[key];
          if (value is int || value is double) return value.toString();
          if (value is String) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty) return trimmed;
          }
        }
      }
      throw ArgumentError('Account id not found in login response');
    }

    String parseUsername() {
      final possibleKeys = ['tenDangNhap', 'TenDangNhap'];
      for (final key in possibleKeys) {
        final value = json[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
      throw ArgumentError('Username not found in login response');
    }

    String parseEmail() {
      final possibleKeys = ['email', 'Email'];
      for (final key in possibleKeys) {
        final value = json[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
      throw ArgumentError('Email not found in login response');
    }

    String? parseCustomerId() {
      final possibleKeys = [
        'maKhachHang',
        'MaKhachHang',
        'maKH',
        'MaKH',
        'makh',
        'MaKh',
      ];
      for (final key in possibleKeys) {
        if (json.containsKey(key) && json[key] != null) {
          final value = json[key];
          if (value is int || value is double) return value.toString();
          if (value is String) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty) return trimmed;
          }
        }
      }
      return null;
    }

    return UserModel(
      maTK: parseAccountId(),
      tenDangNhap: parseUsername(),
      email: parseEmail(),
      maKhachHang: parseCustomerId(),
    );
  }

  /// Convert từ UserModel sang JSON
  Map<String, dynamic> toJson() {
    return {
      'maTK': maTK,
      'tenDangNhap': tenDangNhap,
      'email': email,
      if (maKhachHang != null) 'maKhachHang': maKhachHang,
    };
  }

  /// Copy with method để tạo instance mới với một số field thay đổi
  UserModel copyWith({
    String? maTK,
    String? tenDangNhap,
    String? email,
    String? maKhachHang,
  }) {
    return UserModel(
      maTK: maTK ?? this.maTK,
      tenDangNhap: tenDangNhap ?? this.tenDangNhap,
      email: email ?? this.email,
      maKhachHang: maKhachHang ?? this.maKhachHang,
    );
  }

  @override
  String toString() {
    return 'UserModel(maTK: $maTK, tenDangNhap: $tenDangNhap, email: $email, maKhachHang: $maKhachHang)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.maTK == maTK &&
        other.tenDangNhap == tenDangNhap &&
        other.email == email &&
        other.maKhachHang == maKhachHang;
  }

  @override
  int get hashCode {
    return maTK.hashCode ^
        tenDangNhap.hashCode ^
        email.hashCode ^
        maKhachHang.hashCode;
  }
}
