import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/medicine_by_type.dart';

class MedicineProvider extends ChangeNotifier {
  final List<MedicineByType> medicinesByLoai = [];
  bool isLoading = false;

  Future<void> fetchByLoai(String maLoai) async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await Dio().get(
        "https://localhost:7283/api/Thuoc/ByLoai/$maLoai",
      );

      final data = res.data["data"] as List<dynamic>;

      medicinesByLoai
        ..clear()
        ..addAll(data.map((e) => MedicineByType.fromJson(e)));
    } catch (e) {
      print("ERR fetchByLoai: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
