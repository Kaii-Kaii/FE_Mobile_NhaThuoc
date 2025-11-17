class CartEntry {
  final String medicineId;
  final String name;
  final String? rawImageUrl;
  final String? supplierName;

  final String? optionId; // maGiaThuoc
  final String? unitId; // maLoaiDonVi
  final String unitName; // tenLoaiDonVi
  final int? unitQuantity; // soLuong
  final num price; // donGia
  final int? availableQuantity; // soLuongCon

  int quantity;

  CartEntry({
    required this.medicineId,
    required this.name,
    required this.rawImageUrl,
    required this.supplierName,
    required this.optionId,
    required this.unitId,
    required this.unitName,
    required this.unitQuantity,
    required this.price,
    required this.availableQuantity,
    this.quantity = 1,
  });

  String get key => '${medicineId}__${optionId ?? "default"}';

  num get totalPrice => price * quantity;
}
