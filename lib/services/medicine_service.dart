import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medicine_model.dart';
import '../utils/constants.dart';

class MedicineService {
  // Lấy danh sách tất cả thuốc
  Future<List<Medicine>> getAllMedicines() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/medicines'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Medicine.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load medicines: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting medicines: $e');
    }
  }

  // Lấy chi tiết thuốc theo ID
  Future<Medicine> getMedicineById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/medicines/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Medicine.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load medicine details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting medicine details: $e');
    }
  }

  // Tìm kiếm thuốc theo tên
  Future<List<Medicine>> searchMedicines(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/medicines/search?query=$query'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Medicine.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search medicines: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching medicines: $e');
    }
  }

  // Lọc thuốc theo danh mục
  Future<List<Medicine>> getMedicinesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/medicines/category/$category'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Medicine.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load medicines by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting medicines by category: $e');
    }
  }
}