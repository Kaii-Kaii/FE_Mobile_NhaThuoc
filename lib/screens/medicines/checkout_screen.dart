import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item_model.dart'; // CartEntry
import '../../utils/snackbar_helper.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _note = TextEditingController();

  String paymentMethod = "Thanh toán khi nhận hàng";

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final List<CartEntry> items = cart.items;

    final num subtotal = cart.totalAmount;
    const num shipping = 15000;
    final num total = subtotal + shipping;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text("Thanh toán"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title("Thông tin giao hàng"),
                    _shippingForm(),

                    const SizedBox(height: 24),
                    _title("Phương thức thanh toán"),
                    _paymentSelector(),

                    const SizedBox(height: 24),
                    _title("Đơn hàng của bạn"),
                    _orderSummary(items, subtotal, shipping, total),
                  ],
                ),
              ),
            ),
          ),

          _bottomBar(total),
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  //==========================================================
  // SHIPPING FORM
  //==========================================================
  Widget _shippingForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        children: [
          CustomTextField(
            controller: _name,
            labelText: "Họ và tên",
            prefixIcon: Icons.person,
            validator: (v) => v!.isEmpty ? "Vui lòng nhập họ tên" : null,
          ),
          const SizedBox(height: 14),

          CustomTextField(
            controller: _phone,
            labelText: "Số điện thoại",
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator:
                (v) => v!.length < 10 ? "Số điện thoại không hợp lệ" : null,
          ),
          const SizedBox(height: 14),

          CustomTextField(
            controller: _address,
            labelText: "Địa chỉ giao hàng",
            prefixIcon: Icons.location_on,
            maxLines: 2,
            validator: (v) => v!.isEmpty ? "Vui lòng nhập địa chỉ" : null,
          ),
          const SizedBox(height: 14),

          CustomTextField(
            controller: _note,
            labelText: "Ghi chú (tuỳ chọn)",
            prefixIcon: Icons.note,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  //==========================================================
  // PAYMENT SELECTOR
  //==========================================================
  Widget _paymentSelector() {
    final methods = [
      "Thanh toán khi nhận hàng",
      "Chuyển khoản ngân hàng",
      "Ví điện tử MoMo",
      "Thẻ tín dụng / ghi nợ",
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        children:
            methods.map((m) {
              return RadioListTile(
                title: Text(m),
                value: m,
                groupValue: paymentMethod,
                activeColor: AppTheme.secondaryColor,
                onChanged: (v) => setState(() => paymentMethod = v!),
              );
            }).toList(),
      ),
    );
  }

  //==========================================================
  // ORDER SUMMARY
  //==========================================================
  Widget _orderSummary(
    List<CartEntry> items,
    num subtotal,
    num ship,
    num total,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...items.map((e) => _orderItem(e)),

          const Divider(height: 30),

          _row("Tạm tính", "${subtotal.toInt()} đ"),
          _row("Phí vận chuyển", "${ship.toInt()} đ"),

          const Divider(height: 30),

          _row("Tổng cộng", "${total.toInt()} đ", total: true),
        ],
      ),
    );
  }

  Widget _orderItem(CartEntry e) {
    final img = e.rawImageUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
              image:
                  img != null && img.isNotEmpty
                      ? DecorationImage(
                        image: NetworkImage(img),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                img == null || img.isEmpty
                    ? const Icon(Icons.medication, size: 30)
                    : null,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                Text(
                  "${e.price.toInt()} đ x ${e.quantity}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),

          Text(
            "${e.totalPrice.toInt()} đ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  //==========================================================
  // BOTTOM BAR
  //==========================================================
  Widget _bottomBar(num total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: _box(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tổng thanh toán",
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                "${total.toInt()} đ",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),

          CustomButton(
            text: "Đặt hàng",
            width: 150,
            height: 50,
            color: AppTheme.secondaryColor,
            borderRadius: 10,
            onPressed: _submitOrder,
          ),
        ],
      ),
    );
  }

  //==========================================================
  // SUBMIT ORDER
  //==========================================================
  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      SnackBarHelper.show(
        context,
        "Đặt hàng thành công!",
        type: SnackBarType.success,
      );
    }
  }

  //==========================================================
  // DECORATION
  //==========================================================
  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _row(String l, String v, {bool total = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l,
            style: TextStyle(
              fontSize: total ? 18 : 16,
              fontWeight: total ? FontWeight.bold : FontWeight.normal,
              color: total ? AppTheme.primaryColor : Colors.black87,
            ),
          ),
          Text(
            v,
            style: TextStyle(
              fontSize: total ? 18 : 16,
              fontWeight: total ? FontWeight.bold : FontWeight.normal,
              color: total ? AppTheme.secondaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
