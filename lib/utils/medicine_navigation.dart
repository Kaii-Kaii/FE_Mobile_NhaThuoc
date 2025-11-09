import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../screens/medicines/medicine_list_screen.dart';
import '../screens/medicines/medicine_detail_screen.dart';
import '../screens/medicines/cart_screen.dart';
import '../screens/medicines/checkout_screen.dart';
import '../screens/medicines/family_medicine_screen.dart';
import '../screens/medicines/trusted_brand_screen.dart';

/// Navigation Helper
/// Hỗ trợ điều hướng giữa các màn hình trong ứng dụng
class MedicineNavigation {
  /// Điều hướng đến màn hình danh sách thuốc
  static void goToMedicineList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MedicineListScreen()),
    );
  }
  
  /// Điều hướng đến màn hình danh sách thuốc (alias for goToMedicineList)
  static void navigateToMedicineList(BuildContext context) {
    goToMedicineList(context);
  }
  
  /// Điều hướng đến màn hình tủ thuốc gia đình
  static void goToFamilyMedicine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FamilyMedicineScreen()),
    );
  }
  
  /// Điều hướng đến màn hình thương hiệu tin dùng
  static void goToTrustedBrands(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrustedBrandScreen()),
    );
  }

  /// Điều hướng đến màn hình chi tiết thuốc
  static void goToMedicineDetail(BuildContext context, Medicine medicine) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MedicineDetailScreen(maThuoc: medicine.id.toString())),
    );
  }

  /// Điều hướng đến màn hình giỏ hàng
  static void goToCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  /// Điều hướng đến màn hình thanh toán
  static void goToCheckout(
    BuildContext context, {
    required List<CartItem> cartItems,
    required double subtotal,
    required double shippingFee,
    required double total,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          cartItems: cartItems,
          subtotal: subtotal,
          shippingFee: shippingFee,
          total: total,
        ),
      ),
    );
  }
}