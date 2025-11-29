import 'package:dio/dio.dart';
import '../models/danh_gia_thuoc_model.dart';
import '../models/review_eligibility_model.dart';
import 'api_service.dart';

class DanhGiaService {
  final ApiService _apiService = ApiService();
  final String _baseUrl = '/DanhGiaThuoc';

  /// 1. Lấy 1 đánh giá
  Future<DanhGiaThuocModel?> getReviewById(String maDanhGia) async {
    try {
      final response = await _apiService.get('$_baseUrl/$maDanhGia');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == 1 && data['data'] != null) {
          return DanhGiaThuocModel.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// 2. Lấy danh sách đánh giá theo thuốc
  Future<List<DanhGiaThuocModel>> getReviewsByMedicine(String maThuoc) async {
    try {
      final response = await _apiService.get('$_baseUrl/thuoc/$maThuoc');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        // Check if response is list directly or wrapped
        if (data is List) {
          return data.map((e) => DanhGiaThuocModel.fromJson(e)).toList();
        } else if (data['data'] is List) {
          return (data['data'] as List)
              .map((e) => DanhGiaThuocModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      // If 404 or empty, return empty list?
      return [];
    }
  }

  /// 3. Lấy danh sách đánh giá theo khách hàng
  Future<List<DanhGiaThuocModel>> getReviewsByCustomer(String maKh) async {
    try {
      final response = await _apiService.get('$_baseUrl/khachhang/$maKh');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is List) {
          return data.map((e) => DanhGiaThuocModel.fromJson(e)).toList();
        } else if (data['data'] is List) {
          return (data['data'] as List)
              .map((e) => DanhGiaThuocModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 4. Tạo mới hoặc tự động cập nhật (upsert)
  Future<Map<String, dynamic>> upsertReview({
    required String maKH,
    required String maThuoc,
    required int soSao,
    required String noiDung,
  }) async {
    try {
      final response = await _apiService.post(
        _baseUrl,
        data: {
          'maKH': maKH,
          'maThuoc': maThuoc,
          'soSao': soSao,
          'noiDung': noiDung,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to upsert review');
      }
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        return e.response!.data;
      }
      rethrow;
    }
  }

  /// 5. Cập nhật theo mã đánh giá
  Future<Map<String, dynamic>> updateReview(
    String maDanhGia, {
    required int soSao,
    required String noiDung,
  }) async {
    try {
      final response = await _apiService.put(
        '$_baseUrl/$maDanhGia',
        data: {'soSao': soSao, 'noiDung': noiDung},
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update review');
      }
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        return e.response!.data;
      }
      rethrow;
    }
  }

  /// 6. Xóa đánh giá
  Future<bool> deleteReview(String maDanhGia) async {
    try {
      final response = await _apiService.delete('$_baseUrl/$maDanhGia');
      if (response.statusCode == 200 && response.data != null) {
        // Response.data: true (xóa thành công) hoặc false
        if (response.data is bool) return response.data;
        if (response.data is Map && response.data['data'] == true) return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 7. Kiểm tra quyền đánh giá
  Future<List<ReviewEligibilityModel>> checkEligibility(String maKH) async {
    try {
      final response = await _apiService.get('$_baseUrl/eligible/$maKH');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['data'] is List) {
          return (data['data'] as List)
              .map((e) => ReviewEligibilityModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
