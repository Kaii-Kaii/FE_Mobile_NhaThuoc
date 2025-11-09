import 'package:flutter/foundation.dart';
import '../models/medicine_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void addItem(Medicine medicine, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.medicine.id == medicine.id);

    if (existingIndex >= 0) {
      // Thuốc đã có trong giỏ hàng, chỉ tăng số lượng
      _items[existingIndex].quantity += quantity;
    } else {
      // Thuốc chưa có trong giỏ hàng, thêm mới
      _items.add(CartItem(medicine: medicine, quantity: quantity));
    }
    notifyListeners();
  }

  void removeItem(int medicineId) {
    _items.removeWhere((item) => item.medicine.id == medicineId);
    notifyListeners();
  }

  void updateQuantity(int medicineId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(medicineId);
      return;
    }
    
    final index = _items.indexWhere((item) => item.medicine.id == medicineId);
    if (index >= 0) {
      _items[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  void decreaseQuantity(int medicineId) {
    final index = _items.indexWhere((item) => item.medicine.id == medicineId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items = [];
    notifyListeners();
  }
}