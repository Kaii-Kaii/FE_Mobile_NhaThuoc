class InvoiceDetailModel {
  final String maHD;
  final DateTime ngayLap;
  final String maKH;
  final String tenKH;
  final String diaChiKH;
  final String dienThoaiKH;
  final String maNV;
  final String tenNV;
  final double tongTien;
  final String? ghiChu;
  final int trangThaiGiaoHang;
  final String trangThaiGiaoHangName;

  InvoiceDetailModel({
    required this.maHD,
    required this.ngayLap,
    required this.maKH,
    required this.tenKH,
    required this.diaChiKH,
    required this.dienThoaiKH,
    required this.maNV,
    required this.tenNV,
    required this.tongTien,
    this.ghiChu,
    required this.trangThaiGiaoHang,
    required this.trangThaiGiaoHangName,
  });

  factory InvoiceDetailModel.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailModel(
      maHD: json['maHD'] ?? '',
      ngayLap:
          json['ngayLap'] != null
              ? DateTime.parse(json['ngayLap'])
              : DateTime.now(),
      maKH: json['maKH'] ?? '',
      tenKH: json['tenKH'] ?? '',
      diaChiKH: json['diaChiKH'] ?? '',
      dienThoaiKH: json['dienThoaiKH'] ?? '',
      maNV: json['maNV'] ?? '',
      tenNV: json['tenNV'] ?? '',
      tongTien: (json['tongTien'] as num?)?.toDouble() ?? 0.0,
      ghiChu: json['ghiChu'],
      trangThaiGiaoHang: json['trangThaiGiaoHang'] ?? 0,
      trangThaiGiaoHangName: json['trangThaiGiaoHangName'] ?? '',
    );
  }
}

class InvoiceSummaryItemModel {
  final String maThuoc;
  final String tenThuoc;
  final String? maLD;
  final String? tenLD;
  final String maLoaiDonVi;
  final String tenLoaiDonVi;
  final int tongSoLuong;
  final DateTime? hanSuDungGanNhat;
  final double donGiaTrungBinh;
  final double tongThanhTien;

  InvoiceSummaryItemModel({
    required this.maThuoc,
    required this.tenThuoc,
    this.maLD,
    this.tenLD,
    required this.maLoaiDonVi,
    required this.tenLoaiDonVi,
    required this.tongSoLuong,
    this.hanSuDungGanNhat,
    required this.donGiaTrungBinh,
    required this.tongThanhTien,
  });

  factory InvoiceSummaryItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceSummaryItemModel(
      maThuoc: json['maThuoc'] ?? '',
      tenThuoc: json['tenThuoc'] ?? '',
      maLD: json['maLD'],
      tenLD: json['tenLD'],
      maLoaiDonVi: json['maLoaiDonVi'] ?? '',
      tenLoaiDonVi: json['tenLoaiDonVi'] ?? '',
      tongSoLuong: json['tongSoLuong'] ?? 0,
      hanSuDungGanNhat:
          json['hanSuDungGanNhat'] != null
              ? DateTime.parse(json['hanSuDungGanNhat'])
              : null,
      donGiaTrungBinh: (json['donGiaTrungBinh'] as num?)?.toDouble() ?? 0.0,
      tongThanhTien: (json['tongThanhTien'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class InvoiceDetailResponse {
  final InvoiceDetailModel invoice;
  final List<InvoiceSummaryItemModel> summary;

  InvoiceDetailResponse({required this.invoice, required this.summary});

  factory InvoiceDetailResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return InvoiceDetailResponse(
      invoice: InvoiceDetailModel.fromJson(data['invoice']),
      summary:
          (data['summary'] as List)
              .map((item) => InvoiceSummaryItemModel.fromJson(item))
              .toList(),
    );
  }
}
