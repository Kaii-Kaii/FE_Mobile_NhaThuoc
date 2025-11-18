/// Customer Model
/// Model cho thông tin khách hàng
class CustomerModel {
  final String maKH;
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
    String parseCustomerId() {
      final possibleKeys = ['maKH', 'MaKH', 'makh', 'Makh'];
      for (final key in possibleKeys) {
        if (json.containsKey(key) && json[key] != null) {
          final value = json[key];
          if (value is int || value is double) return value.toString();
          if (value is String) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty) return trimmed;
          }
        }
      }
      throw ArgumentError('Customer id not found in response');
    }

    String parseRequiredString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
        if (value is int || value is double) {
          final coerced = value.toString();
          if (coerced.isNotEmpty) {
            return coerced;
          }
        }
      }
      throw ArgumentError('Missing required string field: ${keys.join('/')}');
    }

    String? parseOptionalString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
        if (value is int || value is double) {
          final coerced = value.toString();
          if (coerced.isNotEmpty) {
            return coerced;
          }
        }
      }
      return null;
    }

    DateTime? parseDate(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        if (value is DateTime) {
          return value;
        }
        if (value is String && value.trim().isNotEmpty) {
          try {
            return DateTime.parse(value.trim());
          } catch (_) {
            continue;
          }
        }
      }
      return null;
    }

    return CustomerModel(
      maKH: parseCustomerId(),
      hoTen: parseRequiredString([
        'hoTen',
        'HoTen',
        'tenKhachHang',
        'TenKhachHang',
      ]),
      dienThoai: parseRequiredString([
        'dienThoai',
        'DienThoai',
        'soDienThoai',
        'SoDienThoai',
      ]),
      ngaySinh: parseDate(['ngaySinh', 'NgaySinh']),
      gioiTinh: parseOptionalString(['gioiTinh', 'GioiTinh']),
      diaChi: parseOptionalString([
        'diaChi',
        'DiaChi',
        'diaChiLienHe',
        'DiaChiLienHe',
      ]),
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
    String? maKH,
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
