class CategoryGroup {
  final String maNhomLoai;
  final String tenNhomLoai;

  CategoryGroup({required this.maNhomLoai, required this.tenNhomLoai});

  factory CategoryGroup.fromJson(Map<String, dynamic> json) => CategoryGroup(
        maNhomLoai: (json['maNhomLoai'] ?? json['MaNhomLoai'] ?? '') as String,
        tenNhomLoai: (json['tenNhomLoai'] ?? json['TenNhomLoai'] ?? json['ten'] ?? '') as String,
      );
}