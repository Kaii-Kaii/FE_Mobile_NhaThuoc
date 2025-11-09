class MedicineDetail {
  final String maThuoc;
  final String? maLoaiThuoc;
  final String tenThuoc;
  final String? thanhPhan;
  final String? moTa;
  final String? congDung;
  final String? cachDung;
  final String? luuY;
  final String? urlAnh;
  final int? soLuong;
  final int? donGiaSi;
  final int? donGiaLe;
  final String? tenNCC;
  final String? tenLoaiDonVi;

  MedicineDetail({
    required this.maThuoc,
    this.maLoaiThuoc,
    required this.tenThuoc,
    this.thanhPhan,
    this.moTa,
    this.congDung,
    this.cachDung,
    this.luuY,
    this.urlAnh,
    this.soLuong,
    this.donGiaSi,
    this.donGiaLe,
    this.tenNCC,
    this.tenLoaiDonVi,
  });

  factory MedicineDetail.fromJson(Map<String, dynamic> j) {
    return MedicineDetail(
      maThuoc: j['maThuoc'] as String? ?? '',
      maLoaiThuoc: j['maLoaiThuoc'] as String?,
      tenThuoc: j['tenThuoc'] as String? ?? '',
      thanhPhan: j['thanhPhan'] as String?,
      moTa: j['moTa'] as String?,
      congDung: j['congDung'] as String?,
      cachDung: j['cachDung'] as String?,
      luuY: j['luuY'] as String?,
      urlAnh: j['urlAnh'] as String?,
      soLuong: j['soLuong'] is int ? j['soLuong'] as int : int.tryParse('${j['soLuong']}'),
      donGiaSi: j['donGiaSi'] is int ? j['donGiaSi'] as int : int.tryParse('${j['donGiaSi']}'),
      donGiaLe: j['donGiaLe'] is int ? j['donGiaLe'] as int : int.tryParse('${j['donGiaLe']}'),
      tenNCC: j['tenNCC'] as String?,
      tenLoaiDonVi: j['tenLoaiDonVi'] as String?,
    );
  }
}
