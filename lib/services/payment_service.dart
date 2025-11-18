import 'package:quan_ly_nha_thuoc/models/payment_models.dart';
import 'package:quan_ly_nha_thuoc/services/api_service.dart';

class PaymentService {
  PaymentService();

  static const String successRedirectUrl =
      'https://app.quanlynhathuoc/payment-success';
  static const String cancelRedirectUrl =
      'https://app.quanlynhathuoc/payment-cancel';

  final ApiService _apiService = ApiService();

  Future<SimplePaymentCreateResponse> createSimplePayment({
    required int amount,
    required String description,
    required String returnUrl,
    required String cancelUrl,
  }) async {
    try {
      final response = await _apiService.post(
        '/SimplePayment/Create',
        data: {
          'amount': amount,
          'description': description,
          'returnUrl': returnUrl,
          'cancelUrl': cancelUrl,
        },
      );

      return SimplePaymentCreateResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception(ApiService.handleError(e));
    }
  }

  Future<SimplePaymentStatusResponse> getPaymentStatus(String orderCode) async {
    try {
      final response = await _apiService.get(
        '/SimplePayment/Status/$orderCode',
      );

      return SimplePaymentStatusResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception(ApiService.handleError(e));
    }
  }
}
