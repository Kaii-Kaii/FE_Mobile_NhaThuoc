/// Customer Model
/// Model cho thông tin khách hàng
class CustomerModel {
  final int maKH;
  final String hoTen;
  final String dienThoai;
  final DateTime? ngaySinh;
  final String? gioiTinh;
  final String? diaChi;

  CustomerModel({
    required this.maKH,
    required this.hoTen,
    required this.dienThoai,
    this.ngaySinh,
    this.gioiTinh,
    this.diaChi,
  });

  /// Convert từ JSON sang CustomerModel
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      maKH: json['makh'] as int? ?? json['maKH'] as int,
      hoTen: json['hoTen'] as String,
      dienThoai: json['dienThoai'] as String,
      ngaySinh:
          json['ngaySinh'] != null
              ? DateTime.parse(json['ngaySinh'] as String)
              : null,
      gioiTinh: json['gioiTinh'] as String?,
      diaChi: json['diaChi'] as String?,
    );
  }

  /// Convert từ CustomerModel sang JSON
  Map<String, dynamic> toJson() {
    return {
      'maKH': maKH,
      'hoTen': hoTen,
      'dienThoai': dienThoai,
      'ngaySinh': ngaySinh?.toIso8601String(),
      'gioiTinh': gioiTinh,
      'diaChi': diaChi,
    };
  }

  /// Copy with method để tạo instance mới với một số field thay đổi
  CustomerModel copyWith({
    int? maKH,
    String? hoTen,
    String? dienThoai,
    DateTime? ngaySinh,
    String? gioiTinh,
    String? diaChi,
  }) {
    return CustomerModel(
      maKH: maKH ?? this.maKH,
      hoTen: hoTen ?? this.hoTen,
      dienThoai: dienThoai ?? this.dienThoai,
      ngaySinh: ngaySinh ?? this.ngaySinh,
      gioiTinh: gioiTinh ?? this.gioiTinh,
      diaChi: diaChi ?? this.diaChi,
    );
  }

  @override
  String toString() {
    return 'CustomerModel(maKH: $maKH, hoTen: $hoTen, dienThoai: $dienThoai, ngaySinh: $ngaySinh, gioiTinh: $gioiTinh, diaChi: $diaChi)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CustomerModel &&
        other.maKH == maKH &&
        other.hoTen == hoTen &&
        other.dienThoai == dienThoai &&
        other.ngaySinh == ngaySinh &&
        other.gioiTinh == gioiTinh &&
        other.diaChi == diaChi;
  }

  @override
  int get hashCode {
    return maKH.hashCode ^
        hoTen.hashCode ^
        dienThoai.hashCode ^
        ngaySinh.hashCode ^
        gioiTinh.hashCode ^
        diaChi.hashCode;
  }
}
