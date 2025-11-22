import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_nha_thuoc/models/order_request.dart';
import 'package:quan_ly_nha_thuoc/providers/cart_provider.dart';
import 'package:quan_ly_nha_thuoc/screens/payments/payment_result_screen.dart';
import 'package:quan_ly_nha_thuoc/services/order_service.dart';
import 'package:quan_ly_nha_thuoc/services/payment_service.dart';
import 'package:quan_ly_nha_thuoc/theme/app_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.orderCode,
    required this.returnUrl,
    required this.cancelUrl,
    required this.orderRequest,
  });

  final String paymentUrl;
  final String orderCode;
  final String returnUrl;
  final String cancelUrl;
  final OnlineOrderRequest orderRequest;

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  final PaymentService _paymentService = PaymentService();
  final OrderService _orderService = OrderService();

  bool _isProcessing = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (request) {
                final url = request.url;
                if (url.startsWith(widget.returnUrl)) {
                  _handleResult(success: true);
                  return NavigationDecision.prevent;
                }
                if (url.startsWith(widget.cancelUrl)) {
                  _handleResult(success: false);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  Future<void> _handleResult({required bool success}) async {
    if (_completed) return;
    _completed = true;

    setState(() {
      _isProcessing = true;
    });

    if (!success) {
      if (!mounted) return;
      _goToResultScreen(false, 'Thanh toán đã bị hủy.');
      return;
    }

    try {
      final status = await _paymentService.getPaymentStatus(widget.orderCode);
      if (!status.isPaid) {
        throw Exception(status.message ?? 'Thanh toán chưa được xác nhận.');
      }

      final maHd = await _orderService.createOnlineOrder(widget.orderRequest);

      print('Created Order ID: $maHd');

      try {
        await _orderService.sendInvoiceEmail(maHd);
      } catch (e) {
        print('Error sending email: $e');
        // Continue even if email sending fails
      }

      if (!mounted) return;
      context.read<CartProvider>().clear();
      _goToResultScreen(true, 'Đơn hàng của bạn đã được tạo thành công.');
    } catch (e) {
      if (!mounted) return;
      _goToResultScreen(false, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _goToResultScreen(bool isSuccess, String message) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => PaymentResultScreen(
              isSuccess: isSuccess,
              title:
                  isSuccess ? 'Thanh toán thành công' : 'Thanh toán thất bại',
              message: message,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán trực tuyến'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
