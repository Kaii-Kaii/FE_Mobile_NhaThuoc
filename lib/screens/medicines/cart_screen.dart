import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_nha_thuoc/utils/snackbar_helper.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_request.dart';
import '../../providers/cart_provider.dart';
import '../../providers/customer_provider.dart';
import '../../screens/payments/payment_webview_screen.dart';
import '../../services/payment_service.dart';
import 'package:quan_ly_nha_thuoc/services/order_service.dart';
import 'package:quan_ly_nha_thuoc/screens/payments/payment_result_screen.dart';
import '../../theme/app_theme.dart';
import 'package:quan_ly_nha_thuoc/screens/main_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const int _shippingFee = 0;
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
    decimalDigits: 0,
  );

  int _paymentMethod = 3; // Default to COD (3)

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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child:
              items.isEmpty
                  ? _buildEmptyCart(context)
                  : Column(
                    children: [
                      Expanded(child: _buildItemList(context, cart)),
                      _buildSummary(context, cart),
                    ],
                  ),
        ),
      ),
    );
  }

  // EMPTY CART UI
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
            onPressed: () {
              MainScreen.of(context)?.setIndex(0);
            },
            child: const Text("Tiếp tục mua sắm"),
          ),
        ],
      ),
    );
  }

  // LIST
  Widget _buildItemList(BuildContext context, CartProvider cart) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: cart.items.length,
      itemBuilder: (_, i) => _buildItem(context, cart, cart.items[i]),
    );
  }

  // ITEM CARD
  Widget _buildItem(BuildContext context, CartProvider cart, CartEntry item) {
    final img =
        (item.rawImageUrl?.startsWith("http") == true)
            ? item.rawImageUrl!
            : "https://res.cloudinary.com/dmu0nknhg/image/upload/v1761064479/thuoc_images/thuoc/${item.rawImageUrl}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemImage(img),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if ((item.supplierName ?? "").isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.supplierName!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text(
                        item.unitName ?? "Đơn vị",
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    ),
                    if (item.unitQuantity != null)
                      Chip(
                        label: Text(
                          "SL/Hộp: ${item.unitQuantity}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Đơn giá",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  _formatCurrency(item.price ?? 0),
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (item.quantity > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Tổng: ${_formatCurrency((item.totalPrice ?? 0))}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // QUANTITY
          _buildQuantityStepper(cart, item),
        ],
      ),
    );
  }

  Widget _buildItemImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        url,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => Container(
              color: Colors.grey[200],
              width: 100,
              height: 100,
              alignment: Alignment.center,
              child: Icon(Icons.broken_image, color: Colors.grey[500]),
            ),
      ),
    );
  }

  Widget _buildQuantityStepper(CartProvider cart, CartEntry item) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => cart.updateQuantity(item.key, item.quantity + 1),
        ),
        Text(
          "${item.quantity}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () => cart.updateQuantity(item.key, item.quantity - 1),
        ),
      ],
    );
  }

  // SUMMARY
  Widget _buildSummary(BuildContext context, CartProvider cart) {
    final total = (cart.totalAmount ?? 0).toInt();
    const shipping = _shippingFee;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Phương thức thanh toán",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildPaymentMethodOption(3, "Thanh toán khi nhận hàng (COD)"),
          _buildPaymentMethodOption(2, "Chuyển khoản QR"),
          const Divider(height: 30),
          _row("Tạm tính", _formatCurrency(total)),
          _row("Phí vận chuyển", _formatCurrency(shipping)),
          const SizedBox(height: 12),
          _row("Tổng cộng", _formatCurrency(total + shipping), bold: true),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () => _handleCheckout(context),
            child: const Text(
              "Tiến hành thanh toán",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(int value, String label) {
    return RadioListTile<int>(
      value: value,
      groupValue: _paymentMethod,
      onChanged: (int? newValue) {
        if (newValue != null) {
          setState(() {
            _paymentMethod = newValue;
          });
        }
      },
      title: Text(label, style: const TextStyle(fontSize: 14)),
      contentPadding: EdgeInsets.zero,
      activeColor: AppTheme.primaryColor,
      dense: true,
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 18 : 16,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 18 : 16,
            color: AppTheme.secondaryColor,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(num value) {
    return '${_currencyFormatter.format(value)} đ';
  }

  // CHECKOUT
  Future<void> _handleCheckout(BuildContext context) async {
    final cart = context.read<CartProvider>();

    if (cart.items.isEmpty) {
      _showSnack(context, "Giỏ hàng đang trống.");
      return;
    }

    final customer = context.read<CustomerProvider>().customer;
    if (customer == null) {
      _showSnack(context, "Vui lòng cập nhật thông tin khách hàng.");
      return;
    }

    final total = (cart.totalAmount ?? 0).toInt();
    final amount = total + _shippingFee;

    final orderItems =
        cart.items.map((item) {
          final price = (item.price ?? 0).round();
          return OnlineOrderItem(
            medicineId: item.medicineId,
            unitId: item.unitId ?? "",
            quantity: item.quantity,
            price: price,
          );
        }).toList();

    // loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (_paymentMethod == 2) {
        // QR Payment
        final orderRequest = OnlineOrderRequest(
          customerId: customer.maKH,
          totalAmount: amount,
          items: orderItems,
          note: "Thanh toán online",
          phuongThucTT: 2,
          // orderCode will be updated after SimplePayment
        );

        final paymentService = PaymentService();
        final resp = await paymentService.createSimplePayment(
          amount: amount,
          description: "Thanh toán đơn hàng",
          returnUrl: PaymentService.successRedirectUrl,
          cancelUrl: PaymentService.cancelRedirectUrl,
        );

        Navigator.pop(context); // Close loading

        if (!resp.success ||
            resp.paymentUrl.isEmpty ||
            resp.orderCode.isEmpty) {
          _showSnack(context, resp.message ?? "Lỗi tạo thanh toán.");
          return;
        }

        // Update orderCode in request
        final updatedRequest = OnlineOrderRequest(
          customerId: orderRequest.customerId,
          totalAmount: orderRequest.totalAmount,
          items: orderRequest.items,
          note: orderRequest.note,
          phuongThucTT: 2,
          orderCode: resp.orderCode,
        );

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => PaymentWebViewScreen(
                  paymentUrl: resp.paymentUrl,
                  orderCode: resp.orderCode,
                  returnUrl: PaymentService.successRedirectUrl,
                  cancelUrl: PaymentService.cancelRedirectUrl,
                  orderRequest: updatedRequest,
                ),
          ),
        );
      } else {
        // COD Payment
        final orderRequest = OnlineOrderRequest(
          customerId: customer.maKH,
          totalAmount: amount,
          items: orderItems,
          note: "Thanh toán COD",
          phuongThucTT: 3,
          orderCode: null,
        );

        final orderService = OrderService();
        final maHd = await orderService.createOnlineOrder(orderRequest);

        Navigator.pop(context); // Close loading

        // Success for COD
        if (!mounted) return;
        context.read<CartProvider>().clear();

        // Navigate to success screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => PaymentResultScreen(
                  isSuccess: true,
                  title: 'Đặt hàng thành công',
                  message:
                      'Đơn hàng của bạn đã được tạo thành công. Mã đơn: $maHd',
                ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      _showSnack(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showSnack(BuildContext context, String msg) {
    SnackBarHelper.show(context, msg, type: SnackBarType.error);
  }
}
