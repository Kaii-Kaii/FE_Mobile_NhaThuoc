class OrderHistoryModel {
  final String maHD;
  final DateTime ngayLap;
  final double tongTien;
  final String? ghiChu;
  final int trangThaiGiaoHang;
  final String trangThaiGiaoHangName;
  final String maNV;
  final String tenNV;

  OrderHistoryModel({
    required this.maHD,
    required this.ngayLap,
    required this.tongTien,
    this.ghiChu,
    required this.trangThaiGiaoHang,
    required this.trangThaiGiaoHangName,
    required this.maNV,
    required this.tenNV,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderHistoryModel(
      maHD: json['maHD'] ?? '',
      ngayLap: DateTime.parse(json['ngayLap']),
      tongTien: (json['tongTien'] as num).toDouble(),
      ghiChu: json['ghiChu'],
      trangThaiGiaoHang: json['trangThaiGiaoHang'] ?? 0,
      trangThaiGiaoHangName: json['trangThaiGiaoHangName'] ?? '',
      maNV: json['maNV'] ?? '',
      tenNV: json['tenNV'] ?? '',
    );
  }
}
