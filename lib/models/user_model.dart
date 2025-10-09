/// User Model
/// Model cho thông tin tài khoản người dùng
class UserModel {
  final int maTK;
  final String tenDangNhap;
  final String email;

  UserModel({
    required this.maTK,
    required this.tenDangNhap,
    required this.email,
  });

  /// Convert từ JSON sang UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      maTK: json['maTK'] as int,
      tenDangNhap: json['tenDangNhap'] as String,
      email: json['email'] as String,
    );
  }

  /// Convert từ UserModel sang JSON
  Map<String, dynamic> toJson() {
    return {'maTK': maTK, 'tenDangNhap': tenDangNhap, 'email': email};
  }

  /// Copy with method để tạo instance mới với một số field thay đổi
  UserModel copyWith({int? maTK, String? tenDangNhap, String? email}) {
    return UserModel(
      maTK: maTK ?? this.maTK,
      tenDangNhap: tenDangNhap ?? this.tenDangNhap,
      email: email ?? this.email,
    );
  }

  @override
  String toString() {
    return 'UserModel(maTK: $maTK, tenDangNhap: $tenDangNhap, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.maTK == maTK &&
        other.tenDangNhap == tenDangNhap &&
        other.email == email;
  }

  @override
  int get hashCode {
    return maTK.hashCode ^ tenDangNhap.hashCode ^ email.hashCode;
  }
}
