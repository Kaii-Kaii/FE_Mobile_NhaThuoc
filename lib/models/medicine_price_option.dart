class MedicinePriceOption {
  final String maGiaThuoc;
  final String maLoaiDonVi;
  final String tenLoaiDonVi;
  final double soLuong;
  final double donGia;
  final bool trangThai;
  final double soLuongCon;

  MedicinePriceOption({
    required this.maGiaThuoc,
    required this.maLoaiDonVi,
    required this.tenLoaiDonVi,
    required this.soLuong,
    required this.donGia,
    required this.trangThai,
    required this.soLuongCon,
  });

  factory MedicinePriceOption.fromJson(Map<String, dynamic> json) {
    return MedicinePriceOption(
      maGiaThuoc: json['maGiaThuoc'] ?? '',
      maLoaiDonVi: json['maLoaiDonVi'] ?? '',
      tenLoaiDonVi: json['tenLoaiDonVi'] ?? '',
      soLuong: _toDouble(json['soLuong']),
      donGia: _toDouble(json['donGia']),
      trangThai: json['trangThai'] ?? false,
      soLuongCon: _toDouble(json['soLuongCon']),
    );
  }
}

double _toDouble(dynamic value, {double defaultValue = 0}) {
  if (value == null) {
    return defaultValue;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? defaultValue;
  }
  return defaultValue;
}
