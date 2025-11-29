class BinhLuanModel {
  final String maBL;
  final String maThuoc;
  final String? maKH;
  final String? maNV;
  final String noiDung;
  final DateTime? thoiGian;
  final String? traLoiChoBinhLuan;
  final List<BinhLuanModel> replies;

  BinhLuanModel({
    required this.maBL,
    required this.maThuoc,
    this.maKH,
    this.maNV,
    required this.noiDung,
    this.thoiGian,
    this.traLoiChoBinhLuan,
    this.replies = const [],
  });

  factory BinhLuanModel.fromJson(Map<String, dynamic> json) {
    return BinhLuanModel(
      maBL: json['maBL'] ?? '',
      maThuoc: json['maThuoc'] ?? '',
      maKH: json['maKH'],
      maNV: json['maNV'],
      noiDung: json['noiDung'] ?? '',
      thoiGian:
          json['thoiGian'] != null ? DateTime.tryParse(json['thoiGian']) : null,
      traLoiChoBinhLuan: json['traLoiChoBinhLuan'],
      replies:
          json['replies'] != null
              ? (json['replies'] as List)
                  .map((e) => BinhLuanModel.fromJson(e))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maBL': maBL,
      'maThuoc': maThuoc,
      'maKH': maKH,
      'maNV': maNV,
      'noiDung': noiDung,
      'thoiGian': thoiGian?.toIso8601String(),
      'traLoiChoBinhLuan': traLoiChoBinhLuan,
      'replies': replies.map((e) => e.toJson()).toList(),
    };
  }
}
