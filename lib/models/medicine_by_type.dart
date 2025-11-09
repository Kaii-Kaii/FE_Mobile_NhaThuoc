class MedicineByType {
  final String maThuoc;
  final String maLoaiThuoc;
  final String tenThuoc;
  final String? moTa;
  final String? urlAnh;
  final num? donGiaSi;
  final String? tenNCC;
  final String? tenLoaiDonVi;

  MedicineByType({
    required this.maThuoc,
    required this.maLoaiThuoc,
    required this.tenThuoc,
    this.moTa,
    this.urlAnh,
    this.donGiaSi,
    this.tenNCC,
    this.tenLoaiDonVi,
  });

  factory MedicineByType.fromJson(Map<String, dynamic> json) {
    return MedicineByType(
      maThuoc: (json['maThuoc'] ?? json['MaThuoc'] ?? '') as String,
      maLoaiThuoc: (json['maLoaiThuoc'] ?? json['MaLoaiThuoc'] ?? '') as String,
      tenThuoc: (json['tenThuoc'] ?? json['TenThuoc'] ?? '') as String,
      moTa: json['moTa'] as String?,
      urlAnh: json['urlAnh'] as String?,
      donGiaSi: json['donGiaSi'] ?? json['DonGiaSi'],
      tenNCC: json['tenNCC'] as String?,
      tenLoaiDonVi: json['tenLoaiDonVi'] as String?,
    );
  }
}
