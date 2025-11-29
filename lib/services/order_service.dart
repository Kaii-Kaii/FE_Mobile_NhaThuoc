import 'package:quan_ly_nha_thuoc/models/invoice_detail_model.dart';
import 'package:quan_ly_nha_thuoc/models/order_history_model.dart';
import 'package:quan_ly_nha_thuoc/models/order_request.dart';
import 'package:quan_ly_nha_thuoc/services/api_service.dart';

class OrderService {
  OrderService();

  final ApiService _apiService = ApiService();

  Future<String> createOnlineOrder(OnlineOrderRequest request) async {
    try {
      final response = await _apiService.post(
        '/HoaDon/CreateOnline',
        data: request.toJson(),
      );

      final maHd = _extractMaHd(response.data);
      if (maHd != null && maHd.isNotEmpty) {
        return maHd;
      }

      return response.data.toString();
    } catch (e) {
      throw Exception(ApiService.handleError(e));
    }
  }

  Future<void> sendInvoiceEmail(String maHd) async {
    try {
      final sanitizedMaHd = maHd.trim();
      if (sanitizedMaHd.isEmpty) {
        throw Exception('Mã hóa đơn không hợp lệ để gửi email.');
      }

      await _apiService.post(
        '/HoaDon/SendToCustomer/${Uri.encodeComponent(sanitizedMaHd)}',
      );
    } catch (e) {
      throw Exception(ApiService.handleError(e));
    }
  }

  Future<List<OrderHistoryModel>> getHistoryByCustomer(
    String customerId,
  ) async {
    try {
      final response = await _apiService.get(
        '/HoaDon/HistoryByKhachHang/$customerId',
      );
      final List<OrderHistoryModel> allOrders = [];

      if (response.data['data'] != null) {
        final data = response.data['data'];

        // Parse history list
        if (data['history'] != null) {
          final List<dynamic> historyList = data['history'];
          allOrders.addAll(
            historyList.map((e) => OrderHistoryModel.fromJson(e)),
          );
        }

        // Parse current list
        if (data['current'] != null) {
          final List<dynamic> currentList = data['current'];
          allOrders.addAll(
            currentList.map((e) => OrderHistoryModel.fromJson(e)),
          );
        }
      }

      // Sort by date descending (optional but good for UX)
      allOrders.sort((a, b) => b.ngayLap.compareTo(a.ngayLap));

      return allOrders;
    } catch (e) {
      throw Exception(ApiService.handleError(e));
    }
  }

  Future<InvoiceDetailResponse> getInvoiceDetail(String invoiceId) async {
    try {
      final response = await _apiService.get(
        '/HoaDon/ChiTiet/Summary/$invoiceId',
      );
      return InvoiceDetailResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(ApiService.handleError(e));
    }
  }

  Future<void> cancelOrder(String maHD) async {
    try {
      await _apiService.patch(
        '/HoaDon/UpdateStatus',
        data: {'maHD': maHD, 'trangThaiGiaoHang': -1},
      );
      await sendInvoiceEmail(maHD);
    } catch (e) {
      throw Exception(ApiService.handleError(e));
    }
  }
}

String? _extractMaHd(dynamic payload) {
  if (payload == null) {
    return null;
  }

  if (payload is String) {
    final trimmed = payload.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  if (payload is num) {
    return payload.toString();
  }

  if (payload is Map) {
    final map = Map<String, dynamic>.from(payload);

    const possibleKeys = ['maHD', 'maHd', 'MaHD', 'MaHd', 'mahd', 'MAHD'];

    for (final key in possibleKeys) {
      if (map.containsKey(key)) {
        final result = _extractMaHd(map[key]);
        if (result != null) {
          return result;
        }
      }
    }

    const nestedKeys = ['data', 'invoice', 'hoaDon'];
    for (final key in nestedKeys) {
      if (map.containsKey(key)) {
        final result = _extractMaHd(map[key]);
        if (result != null) {
          return result;
        }
      }
    }

    for (final value in map.values) {
      final result = _extractMaHd(value);
      if (result != null) {
        return result;
      }
    }
  }

  if (payload is Iterable) {
    for (final element in payload) {
      final result = _extractMaHd(element);
      if (result != null) {
        return result;
      }
    }
  }

  return null;
}
