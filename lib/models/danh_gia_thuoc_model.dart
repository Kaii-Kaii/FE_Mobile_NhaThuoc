class DanhGiaThuocModel {
  final String maDanhGia;
  final String maKH;
  final String maThuoc;
  final int soSao;
  final String noiDung;
  final DateTime? ngayDanhGia;

  DanhGiaThuocModel({
    required this.maDanhGia,
    required this.maKH,
    required this.maThuoc,
    required this.soSao,
    required this.noiDung,
    this.ngayDanhGia,
  });

  factory DanhGiaThuocModel.fromJson(Map<String, dynamic> json) {
    return DanhGiaThuocModel(
      maDanhGia: json['maDanhGia'] ?? '',
      maKH: json['maKH'] ?? '',
      maThuoc: json['maThuoc'] ?? '',
      soSao:
          json['soSao'] is int
              ? json['soSao']
              : (json['soSao'] as num?)?.toInt() ?? 0,
      noiDung: json['noiDung'] ?? '',
      ngayDanhGia:
          json['ngayDanhGia'] != null
              ? DateTime.tryParse(json['ngayDanhGia'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maDanhGia': maDanhGia,
      'maKH': maKH,
      'maThuoc': maThuoc,
      'soSao': soSao,
      'noiDung': noiDung,
      'ngayDanhGia': ngayDanhGia?.toIso8601String(),
    };
  }
}
