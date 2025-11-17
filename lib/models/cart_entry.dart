class CartEntry {
  final String medicineId;
  final String name;
  final String? rawImageUrl;
  final String? supplierName;

  final String? optionId;
  final String? unitId;
  final String? unitName;
  final double? unitQuantity;     // <− đổi từ int → double
  final double? price;            // <− đổi từ int → double
  final double? availableQuantity; // <− đổi từ int → double

  int quantity;

  CartEntry({
    required this.medicineId,
    required this.name,
    this.rawImageUrl,
    this.supplierName,
    this.optionId,
    this.unitId,
    this.unitName,
    this.unitQuantity,
    this.price,
    this.availableQuantity,
    required this.quantity,
  });

  double get totalPrice => (price ?? 0) * quantity;
}
