class OnlineOrderItem {
  final String medicineId;
  final String unitId;
  final int quantity;
  final int price;

  OnlineOrderItem({
    required this.medicineId,
    required this.unitId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'maThuoc': medicineId,
      'donVi': unitId,
      'soLuong': quantity,
      'donGia': price,
    };
  }
}

class OnlineOrderRequest {
  final String customerId;
  final int totalAmount;
  final String? note;
  final List<OnlineOrderItem> items;

  OnlineOrderRequest({
    required this.customerId,
    required this.totalAmount,
    required this.items,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'maKH': customerId,
      'ghiChu': note ?? '',
      'tongTien': totalAmount,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
