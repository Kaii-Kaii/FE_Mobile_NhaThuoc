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
}
