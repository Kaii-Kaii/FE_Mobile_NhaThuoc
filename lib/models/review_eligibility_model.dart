class ReviewEligibilityModel {
  final String maThuoc;
  final String tenThuoc;
  final bool daDanhGia;
  final String? maDanhGia;
  final int? soSao;

  ReviewEligibilityModel({
    required this.maThuoc,
    required this.tenThuoc,
    required this.daDanhGia,
    this.maDanhGia,
    this.soSao,
  });

  factory ReviewEligibilityModel.fromJson(Map<String, dynamic> json) {
    return ReviewEligibilityModel(
      maThuoc: json['maThuoc'] ?? '',
      tenThuoc: json['tenThuoc'] ?? '',
      daDanhGia: json['daDanhGia'] ?? false,
      maDanhGia: json['maDanhGia'],
      soSao: json['soSao'],
    );
  }
}
