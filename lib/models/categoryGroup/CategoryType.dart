class CategoryType {
  final String maLoaiThuoc;
  final String tenLoaiThuoc;
  final String maNhomLoai;
  final String? icon;

  CategoryType({required this.maLoaiThuoc, required this.tenLoaiThuoc, required this.maNhomLoai, this.icon});

  factory CategoryType.fromJson(Map<String, dynamic> json) => CategoryType(
        maLoaiThuoc: (json['maLoaiThuoc'] ?? json['MaLoaiThuoc'] ?? '') as String,
        tenLoaiThuoc: (json['tenLoaiThuoc'] ?? json['TenLoaiThuoc'] ?? json['ten'] ?? '') as String,
        maNhomLoai: (json['maNhomLoai'] ?? json['MaNhomLoai'] ?? '') as String,
        icon: json['icon'] as String?,
      );

  /// Build full URL for icon file from server.
  /// Icons are stored on the server at: https://10.0.2.2:7283/assets_user/img/icon/
  /// This strips the '/api' prefix from baseUrl and constructs the full icon URL
  String? get iconUrl {
    if (icon == null || icon!.isEmpty) return null;
    // Remove '/api' from the base URL to get the server root
    // https://10.0.2.2:7283/api -> https://10.0.2.2:7283
    const baseUrl = 'https://10.0.2.2:7283';
    return '$baseUrl/assets_user/img/icon/${icon!}';
  }
}
