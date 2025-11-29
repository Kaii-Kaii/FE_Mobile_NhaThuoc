import '../models/binh_luan_model.dart';
import 'api_service.dart';

class BinhLuanService {
  final ApiService _apiService = ApiService();
  final String _baseUrl = '/BinhLuan';

  // 1. Get comment by ID
  Future<BinhLuanModel?> getCommentById(String maBL) async {
    try {
      final response = await _apiService.get('$_baseUrl/$maBL');
      if (response.statusCode == 200 && response.data != null) {
        return BinhLuanModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // 2. Get comments by medicine
  Future<List<BinhLuanModel>> getCommentsByMedicine(String maThuoc) async {
    try {
      final response = await _apiService.get('$_baseUrl/thuoc/$maThuoc');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is List) {
          return data.map((e) => BinhLuanModel.fromJson(e)).toList();
        } else if (data is Map && data['data'] is List) {
          return (data['data'] as List)
              .map((e) => BinhLuanModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 3. Create comment/reply
  Future<BinhLuanModel?> createComment({
    required String maThuoc,
    String? maKH,
    String? maNV,
    required String noiDung,
    String? traLoiChoBinhLuan,
  }) async {
    try {
      final response = await _apiService.post(
        _baseUrl,
        data: {
          'maThuoc': maThuoc,
          'maKH': maKH,
          'maNV': maNV,
          'noiDung': noiDung,
          'traLoiChoBinhLuan': traLoiChoBinhLuan,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // The API returns the created comment
        if (response.data is Map<String, dynamic>) {
          return BinhLuanModel.fromJson(response.data);
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // 4. Delete comment
  Future<bool> deleteComment(String maBL) async {
    try {
      final response = await _apiService.delete('$_baseUrl/$maBL');
      if (response.statusCode == 200) {
        if (response.data is bool) return response.data;
        if (response.data is Map && response.data['data'] == true) return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
