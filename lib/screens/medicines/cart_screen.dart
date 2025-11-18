import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_request.dart';
import '../../providers/cart_provider.dart';
import '../../providers/customer_provider.dart';
import '../../screens/payments/payment_webview_screen.dart';
import '../../services/payment_service.dart';
import '../../theme/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const int _shippingFee = 0;
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
    decimalDigits: 0,
  );

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
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor.withOpacity(0.05),
                AppTheme.backgroundColor,
              ],
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child:
                items.isEmpty
                    ? _buildEmptyCart(context)
                    : Column(
                      key: const ValueKey('cart_loaded'),
                      children: [
                        Expanded(child: _buildItemList(context, cart)),
                        _buildSummary(context, cart),
                      ],
                    ),
          ),
        ),
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
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: cart.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (_, index) {
        final item = cart.items[index];
        return _buildItem(context, cart, item);
      },
    );
  }

  Widget _buildItem(BuildContext context, CartProvider cart, CartEntry item) {
    final imageUrl =
        (item.rawImageUrl != null &&
                (item.rawImageUrl!.startsWith("http") ||
                    item.rawImageUrl!.startsWith("https")))
            ? item.rawImageUrl!
            : "https://res.cloudinary.com/dmu0nknhg/image/upload/v1761064479/thuoc_images/thuoc/${item.rawImageUrl}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppTheme.primaryColor.withOpacity(0.04)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildItemImage(imageUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      if (item.supplierName?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            item.supplierName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Chip(
                            backgroundColor: AppTheme.primaryColor.withOpacity(
                              0.08,
                            ),
                            label: Text(
                              item.unitName,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (item.unitQuantity != null)
                            Chip(
                              backgroundColor: Colors.grey[100],
                              label: Text(
                                'SL/Hộp: ${item.unitQuantity}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Đơn giá',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatCurrency(item.price),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppTheme.secondaryColor,
                                  ),
                                ),
                                if (item.quantity > 1) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tổng: ${_formatCurrency(item.totalPrice)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          _buildQuantityStepper(cart, item),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              child: IconButton(
                tooltip: 'Xoá khỏi giỏ',
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () => cart.removeItem(item.key),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 110,
        height: 110,
        color: Colors.white,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.2),
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.broken_image,
                      size: 36,
                      color: Colors.grey[500],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityStepper(CartProvider cart, CartEntry item) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(
            icon: Icons.remove_rounded,
            onTap: () => cart.updateQuantity(item.key, item.quantity - 1),
          ),
          Container(
            alignment: Alignment.center,
            width: 34,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          _qtyBtn(
            icon: Icons.add_rounded,
            onTap: () => cart.updateQuantity(item.key, item.quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: AppTheme.primaryColor),
        ),
      ),
    );
  }

  // ---------------- SUMMARY -------------------
  Widget _buildSummary(BuildContext context, CartProvider cart) {
    final total = cart.totalAmount;
    const shipping = _shippingFee;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Thông tin đơn hàng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${cart.items.length} sản phẩm',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          _row("Tạm tính", _formatCurrency(total)),
          _row("Phí vận chuyển", _formatCurrency(shipping)),

          const Divider(height: 28),
          _row("Tổng cộng", _formatCurrency(total + shipping), bold: true),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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

  String _formatCurrency(num? value) {
    final safeValue = value ?? 0;
    return '${_currencyFormatter.format(safeValue).trim()} đ';
  }

  Future<void> _handleCheckout(BuildContext context) async {
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) {
      _showSnack(context, 'Giỏ hàng của bạn đang trống.');
      return;
    }

    final customer = context.read<CustomerProvider>().customer;
    if (customer == null) {
      _showSnack(
        context,
        'Vui lòng cập nhật thông tin khách hàng trước khi thanh toán.',
      );
      return;
    }

    final total = cart.totalAmount.toInt();
    final amount = total + _shippingFee;

    final orderItems =
        cart.items.map((item) {
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
        final message =
            paymentResponse.message ??
            'Không thể khởi tạo thanh toán. Vui lòng thử lại sau.';
        _showSnack(context, message);
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => PaymentWebViewScreen(
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
      _showSnack(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
