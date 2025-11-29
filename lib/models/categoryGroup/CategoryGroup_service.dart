import 'package:dio/dio.dart';
import 'package:quan_ly_nha_thuoc/services/api_service.dart';
import 'package:quan_ly_nha_thuoc/models/categoryGroup/CategoryGroup.dart';
import 'package:quan_ly_nha_thuoc/models/categoryGroup/CategoryType.dart';

class CategoryGroupService {
  final ApiService _api = ApiService();

  /// Lấy danh sách nhóm loại từ endpoint NhomLoai
  /// Trả về danh sách các CategoryGroup
  Future<List<CategoryGroup>> getAllCategoryGroups() async {
    try {
      // NOTE: ApiService.baseUrl already contains the "/api" prefix.
      // Do NOT start the path with a leading '/' so Dio will append it correctly.
      // Ensure leading slash so baseUrl ('.../api') combines correctly to '/api/NhomLoai'
      final Response response = await _api.get('/NhomLoai/WithLoai');

      // Server trả về object: { status: 1, message: ..., data: [...] }
      if (response.statusCode == 200) {
        final body = response.data;

        if (body is Map<String, dynamic>) {
          final data = body['data'];
          if (data is List) {
            return data
                .map((e) => CategoryGroup.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          // Nếu server trả về dạng khác (ví dụ data là null), trả về danh sách rỗng
          return <CategoryGroup>[];
        }

        // Nếu body là List trực tiếp
        if (body is List) {
          return body
              .map((e) => CategoryGroup.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        throw Exception('Unexpected response format from /NhomLoai');
      }

      throw Exception('Failed to load category groups: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(ApiService.handleError(e));
    } catch (e) {
      throw Exception('Error getting category groups: $e');
    }
  }

  /// Lấy danh sách loại theo mã nhóm: /NhomLoai/Loai/{maNhomLoai}
  Future<List<CategoryType>> getTypesByGroup(String maNhomLoai) async {
    try {
      final Response response = await _api.get('/NhomLoai/Loai/$maNhomLoai');

      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map<String, dynamic>) {
          final data = body['data'];
          if (data is List) {
            return data
                .map((e) => CategoryType.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return <CategoryType>[];
        }

        if (body is List) {
          return body
              .map((e) => CategoryType.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        throw Exception(
          'Unexpected response format from /NhomLoai/Loai/$maNhomLoai',
        );
      }

      throw Exception('Failed to load category types: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(ApiService.handleError(e));
    } catch (e) {
      throw Exception('Error getting category types: $e');
    }
  }
}
