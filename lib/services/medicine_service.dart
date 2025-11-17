import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/medicine_by_type.dart';
import '../models/medicine_detail.dart';

class MedicineService {
  // Lấy danh sách thuốc theo loại
  Future<List<MedicineByType>> getByLoai(String maLoaiThuoc) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/Thuoc/ByLoai/$maLoaiThuoc');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);

      final List<dynamic> list = jsonBody["data"] ?? [];

      return list.map((e) => MedicineByType.fromJson(e)).toList();
    }

    throw Exception("Lỗi: ${response.statusCode}");
  }

  // Lấy chi tiết thuốc theo mã
  Future<MedicineDetail> getDetail(String maThuoc) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/Thuoc/$maThuoc');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return MedicineDetail.fromJson(jsonBody["data"]);
    }

    throw Exception("Lỗi: ${response.statusCode}");
  }
}
