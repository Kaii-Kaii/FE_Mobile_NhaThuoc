import 'medicine_price_option.dart';
import 'medicine_by_type.dart';

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
  final String? tenNCC;

  /// Danh sách các loại giá / đơn vị thuốc
  final List<MedicinePriceOption> giaThuocs;

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
    this.tenNCC,
    required this.giaThuocs,
  });

  factory MedicineDetail.fromJson(Map<String, dynamic> j) {
    return MedicineDetail(
      maThuoc: j['maThuoc'] ?? '',
      maLoaiThuoc: j['maLoaiThuoc'],
      tenThuoc: j['tenThuoc'] ?? '',
      thanhPhan: j['thanhPhan'],
      moTa: j['moTa'],
      congDung: j['congDung'],
      cachDung: j['cachDung'],
      luuY: j['luuY'],
      urlAnh: j['urlAnh'],
      tenNCC: j['tenNCC'],
      giaThuocs:
          (j['giaThuocs'] as List<dynamic>? ?? [])
              .map((x) => MedicinePriceOption.fromJson(x))
              .toList(),
    );
  }

  /// Convert từ MedicineDetail sang MedicineByType để CartProvider dùng
  MedicineByType toByType() {
    return MedicineByType(
      maThuoc: maThuoc,
      tenThuoc: tenThuoc,
      urlAnh: urlAnh,
      tenNCC: tenNCC,
      tenLoaiDonVi: null, // Detail API không trả, Cart sẽ lấy từ Option
      donGiaSi: null, // Detail API không có donGiaSi
      giaThuocs: giaThuocs,
    );
  }
}
