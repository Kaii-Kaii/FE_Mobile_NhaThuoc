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
  final int phuongThucTT;
  final String? orderCode;

  OnlineOrderRequest({
    required this.customerId,
    required this.totalAmount,
    required this.items,
    this.note,
    required this.phuongThucTT,
    this.orderCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'maKH': customerId,
      'ghiChu': note ?? '',
      'tongTien': totalAmount,
      'phuongThucTT': phuongThucTT,
      'orderCode': orderCode,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
