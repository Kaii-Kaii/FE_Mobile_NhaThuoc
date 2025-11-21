import 'package:quan_ly_nha_thuoc/models/invoice_detail_model.dart';
import 'package:quan_ly_nha_thuoc/models/order_history_model.dart';
import 'package:quan_ly_nha_thuoc/models/order_request.dart';
import 'package:quan_ly_nha_thuoc/services/api_service.dart';

class OrderService {
  OrderService();

  final ApiService _apiService = ApiService();

  Future<void> createOnlineOrder(OnlineOrderRequest request) async {
    try {
      await _apiService.post('/HoaDon/CreateOnline', data: request.toJson());
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
}
