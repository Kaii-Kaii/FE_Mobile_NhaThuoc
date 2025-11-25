import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/medicine_by_type.dart';
import '../models/medicine_price_option.dart';

class CartProvider extends ChangeNotifier {
  final List<CartEntry> _items = [];

  List<CartEntry> get items => _items;

  num get totalAmount => _items.fold(0, (sum, e) => sum + e.totalPrice);

  /// THÊM THUỐC VÀO GIỎ
  void addMedicine({
    required MedicineByType medicine,
    required MedicinePriceOption? option,
    int quantity = 1,
  }) {
    final key = '${medicine.maThuoc}__${option?.maGiaThuoc ?? "default"}';

    final index = _items.indexWhere((e) => e.key == key);

    if (index >= 0) {
      // Đã có trong giỏ → tăng số lượng
      _items[index].quantity += quantity;
    } else {
      // Thêm mới
      _items.add(
        CartEntry(
          medicineId: medicine.maThuoc,
          name: medicine.tenThuoc,
          rawImageUrl: medicine.urlAnh,
          supplierName: medicine.tenNCC,
          optionId: option?.maGiaThuoc,
          unitId: option?.maLoaiDonVi,
          unitName: option?.tenLoaiDonVi ?? medicine.tenLoaiDonVi ?? "Đơn vị",
          unitQuantity: option?.soLuong.toInt(),
          price: option?.donGia ?? medicine.donGiaSi ?? 0,
          availableQuantity: option?.soLuongCon.toInt(),
          quantity: quantity,
        ),
      );
    }

    notifyListeners();
  }

  /// XOÁ 1 ITEM
  void removeItem(String key) {
    _items.removeWhere((e) => e.key == key);
    notifyListeners();
  }

  /// THAY ĐỔI SỐ LƯỢNG
  void updateQuantity(String key, int newQuantity) {
    final index = _items.indexWhere((e) => e.key == key);
    if (index == -1) return;

    if (newQuantity <= 0) {
      removeItem(key);
    } else {
      _items[index].quantity = newQuantity;
    }

    notifyListeners();
  }

  /// GIẢM SỐ LƯỢNG
  void decreaseQuantity(String key) {
    final index = _items.indexWhere((e) => e.key == key);
    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  /// XOÁ GIỎ
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
