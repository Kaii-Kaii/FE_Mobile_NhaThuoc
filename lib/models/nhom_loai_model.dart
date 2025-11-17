class LoaiThuoc {
  final String maLoaiThuoc;
  final String tenLoaiThuoc;
  final String icon;

  LoaiThuoc({
    required this.maLoaiThuoc,
    required this.tenLoaiThuoc,
    required this.icon,
  });

  factory LoaiThuoc.fromJson(Map<String, dynamic> j) {
    return LoaiThuoc(
      maLoaiThuoc: j['maLoaiThuoc'],
      tenLoaiThuoc: j['tenLoaiThuoc'],
      icon: j['icon'],
    );
  }
}

class NhomLoai {
  final String maNhomLoai;
  final String tenNhomLoai;
  final List<LoaiThuoc> loai;

  NhomLoai({
    required this.maNhomLoai,
    required this.tenNhomLoai,
    required this.loai,
  });

  factory NhomLoai.fromJson(Map<String, dynamic> j) {
    return NhomLoai(
      maNhomLoai: j['maNhomLoai'],
      tenNhomLoai: j['tenNhomLoai'],
      loai: (j['loai'] as List).map((x) => LoaiThuoc.fromJson(x)).toList(),
    );
  }
}
