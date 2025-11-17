import 'medicine_price_option.dart';

class MedicineByType {
  final String maThuoc;
  final String tenThuoc;
  final String? moTa;
  final String? tenNCC;
  final String? urlAnh;
  final String? tenLoaiDonVi;
  final double? donGiaSi;

  final List<MedicinePriceOption> giaThuocs;

  MedicineByType({
    required this.maThuoc,
    required this.tenThuoc,
    this.moTa,
    this.tenNCC,
    this.urlAnh,
    this.tenLoaiDonVi,
    this.donGiaSi,
    required this.giaThuocs,
  });

  factory MedicineByType.fromJson(Map<String, dynamic> j) {
    return MedicineByType(
      maThuoc: j['maThuoc'] ?? '',
      tenThuoc: j['tenThuoc'] ?? '',
      moTa: j['moTa'],
      tenNCC: j['tenNCC'],
      urlAnh: j['urlAnh'],
      tenLoaiDonVi: j['tenLoaiDonVi'],
      donGiaSi: _toNullableDouble(j['donGiaSi']),
      giaThuocs:
          (j['giaThuocs'] as List<dynamic>? ?? [])
              .map((x) => MedicinePriceOption.fromJson(x))
              .toList(),
    );
  }
}

double? _toNullableDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}
