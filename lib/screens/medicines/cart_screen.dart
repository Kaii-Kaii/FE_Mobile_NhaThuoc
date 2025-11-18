import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_request.dart';
import '../../providers/cart_provider.dart';
import '../../providers/customer_provider.dart';
import '../../screens/payments/payment_webview_screen.dart';
import '../../services/payment_service.dart';
import '../../theme/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const int _shippingFee = 0;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text("Giỏ hàng"),
      ),

      body:
          items.isEmpty
              ? _buildEmptyCart(context)
              : Column(
                children: [
                  Expanded(child: _buildItemList(context, cart)),
                  _buildSummary(context, cart),
                ],
              ),
    );
  }

  // ---------------- EMPTY ------------------
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            "Giỏ hàng trống",
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text("Hãy thêm sản phẩm vào giỏ"),
          const SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Tiếp tục mua sắm"),
          ),
        ],
      ),
    );
  }

  // ---------------- LIST -------------------
  Widget _buildItemList(BuildContext context, CartProvider cart) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cart.items.length,
      itemBuilder: (_, index) {
        final item = cart.items[index];
        return _buildItem(context, cart, item);
      },
    );
  }

  Widget _buildItem(BuildContext context, CartProvider cart, item) {
    final imageUrl =
        (item.rawImageUrl != null &&
                (item.rawImageUrl!.startsWith("http") ||
                    item.rawImageUrl!.startsWith("https")))
            ? item.rawImageUrl!
            : "https://res.cloudinary.com/dmu0nknhg/image/upload/v1761064479/thuoc_images/thuoc/${item.rawImageUrl}";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Image.network(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
            ),
          ),

          // INFO
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    item.unitName,
                    style: TextStyle(color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "${item.price.toInt()} đ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // QUANTITY
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _qtyBtn(
                  icon: Icons.remove,
                  onTap: () => cart.updateQuantity(item.key, item.quantity - 1),
                ),
                Container(
                  width: 30,
                  alignment: Alignment.center,
                  child: Text(
                    "${item.quantity}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _qtyBtn(
                  icon: Icons.add,
                  onTap: () => cart.updateQuantity(item.key, item.quantity + 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18),
      ),
    );
  }

  // ---------------- SUMMARY -------------------
  Widget _buildSummary(BuildContext context, CartProvider cart) {
    final total = cart.totalAmount.toInt();
    const shipping = _shippingFee;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Thông tin đơn hàng",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),
          _row("Tạm tính", "$total đ"),
          _row("Phí vận chuyển", "$shipping đ"),

          const Divider(height: 28),
          _row("Tổng cộng", "${total + shipping} đ", bold: true),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => _handleCheckout(context),
              child: const Text(
                "Tiến hành thanh toán",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 18 : 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 18 : 16,
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

    Future<void> _handleCheckout(BuildContext context) async {
      final cart = context.read<CartProvider>();
      if (cart.items.isEmpty) {
        _showSnack(context, 'Giỏ hàng của bạn đang trống.');
        return;
      }

      final customer = context.read<CustomerProvider>().customer;
      if (customer == null) {
        _showSnack(context, 'Vui lòng cập nhật thông tin khách hàng trước khi thanh toán.');
        return;
      }

      final total = cart.totalAmount.toInt();
      final amount = total + _shippingFee;

      final orderItems = cart.items.map((item) {
        final price = item.price.round();
        return OnlineOrderItem(
          medicineId: item.medicineId,
          unitId: item.unitId ?? '',
          quantity: item.quantity,
          price: price,
        );
      }).toList();

      final orderRequest = OnlineOrderRequest(
        customerId: customer.maKH,
        totalAmount: amount,
        items: orderItems,
        note: 'Thanh toán online',
      );

      final paymentService = PaymentService();

      var loadingVisible = false;
      if (context.mounted) {
        loadingVisible = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return const Center(child: CircularProgressIndicator());
          },
        );
      }

      try {
        final paymentResponse = await paymentService.createSimplePayment(
          amount: amount,
          description: 'Thanh toán đơn hàng',
          returnUrl: PaymentService.successRedirectUrl,
          cancelUrl: PaymentService.cancelRedirectUrl,
        );

        if (loadingVisible && context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          loadingVisible = false;
        }

        if (!context.mounted) return;

        if (!paymentResponse.success ||
            paymentResponse.paymentUrl.isEmpty ||
            paymentResponse.orderCode.isEmpty) {
          final message = paymentResponse.message ??
              'Không thể khởi tạo thanh toán. Vui lòng thử lại sau.';
          _showSnack(context, message);
          return;
        }

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaymentWebViewScreen(
              paymentUrl: paymentResponse.paymentUrl,
              orderCode: paymentResponse.orderCode,
              returnUrl: PaymentService.successRedirectUrl,
              cancelUrl: PaymentService.cancelRedirectUrl,
              orderRequest: orderRequest,
            ),
          ),
        );
      } catch (e) {
        if (loadingVisible && context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          loadingVisible = false;
        }
        if (!context.mounted) return;
        _showSnack(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }

    void _showSnack(BuildContext context, String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
}
