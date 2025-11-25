import 'package:flutter/material.dart';
import '../screens/medicines/medicine_list_screen.dart';
import '../screens/medicines/medicine_detail_screen.dart';
import '../screens/medicines/family_medicine_screen.dart';
import '../screens/medicines/trusted_brand_screen.dart';

/// Bộ điều hướng chung
class MedicineNavigation {
  /// Điều hướng đến danh sách thuốc theo mã loại
  static void goToMedicineList(BuildContext context, String maLoaiThuoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MedicineListScreen(maLoaiThuoc: maLoaiThuoc),
      ),
    );
  }

  /// Alias cho dễ dùng
  static void navigateToMedicineList(BuildContext context, String maLoaiThuoc) {
    goToMedicineList(context, maLoaiThuoc);
  }

  /// Điều hướng đến màn hình tủ thuốc
  static void goToFamilyMedicine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FamilyMedicineScreen()),
    );
  }

  /// Điều hướng đến màn hình thương hiệu
  static void goToTrustedBrands(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TrustedBrandScreen()),
    );
  }

  /// Điều hướng đến màn hình chi tiết thuốc
  static void goToMedicineDetail(BuildContext context, String maThuoc) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MedicineDetailScreen(maThuoc: maThuoc)),
    );
  }
}
