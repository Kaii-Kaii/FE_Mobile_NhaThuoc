import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/medicine_model.dart';
import './checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Dummy data cho giao diện
  final List<CartItem> _dummyCartItems = [
    CartItem(
      medicine: Medicine(
        id: 1,
        name: 'Paracetamol',
        description: 'Thuốc giảm đau, hạ sốt',
        price: 15000,
        image: 'https://cdn.nhathuoclongchau.com.vn/unsafe/373x0/filters:quality(90)/https://cms-prod.s3-sgn09.fptcloud.com/00502L_paracetamol_500mg_hapharco_hop_10_vi_x_10_vien_7302_61c1_large_92f99a9343.JPG',
        category: 'Thuốc không kê đơn',
        stockQuantity: 100,
        manufacturer: 'Dược Hậu Giang',
        dosageForm: 'Viên nén',
        dosageInstructions: 'Uống 1-2 viên mỗi 4-6 giờ khi cần',
        requiresPrescription: false,
      ),
      quantity: 2,
    ),
    CartItem(
      medicine: Medicine(
        id: 3,
        name: 'Vitamin C',
        description: 'Bổ sung vitamin C',
        price: 35000,
        image: 'https://cdn.nhathuoclongchau.com.vn/unsafe/373x0/filters:quality(90)/https://cms-prod.s3-sgn09.fptcloud.com/DSC_00743_81b06b33d3.jpg',
        category: 'Thực phẩm chức năng',
        stockQuantity: 200,
        manufacturer: 'Pharma',
        dosageForm: 'Viên nén sủi',
        dosageInstructions: 'Uống 1 viên/ngày',
        requiresPrescription: false,
      ),
      quantity: 1,
    ),
  ];

  double get _totalAmount {
    return _dummyCartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Giỏ hàng'),
        elevation: 0,
      ),
      body: _dummyCartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: _buildCartItemList(),
                ),
                _buildOrderSummary(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
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
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Back to medicines list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Tiếp tục mua sắm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _dummyCartItems.length,
      itemBuilder: (context, index) {
        final cartItem = _dummyCartItems[index];
        return _buildCartItemCard(cartItem);
      },
    );
  }

  Widget _buildCartItemCard(CartItem cartItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hình ảnh thuốc
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
            child: Image.network(
              cartItem.medicine.image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  alignment: Alignment.center,
                  width: 100,
                  height: 100,
                );
              },
            ),
          ),
          // Thông tin thuốc
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.medicine.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cartItem.medicine.manufacturer} • ${cartItem.medicine.dosageForm}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${cartItem.medicine.price.toInt().toString()} đ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Số lượng
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildQuantityButton(
                  icon: Icons.remove,
                  onPressed: () {
                    setState(() {
                      if (cartItem.quantity > 1) {
                        cartItem.quantity--;
                      } else {
                        _dummyCartItems.remove(cartItem);
                      }
                    });
                  },
                ),
                Container(
                  width: 30,
                  alignment: Alignment.center,
                  child: Text(
                    cartItem.quantity.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _buildQuantityButton(
                  icon: Icons.add,
                  onPressed: () {
                    setState(() {
                      if (cartItem.quantity < cartItem.medicine.stockQuantity) {
                        cartItem.quantity++;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin đơn hàng',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Tạm tính', '${_totalAmount.toInt().toString()} đ'),
          _buildSummaryRow('Phí vận chuyển', '15,000 đ'),
          const Divider(height: 32),
          _buildSummaryRow(
            'Tổng cộng',
            '${(_totalAmount + 15000).toInt().toString()} đ',
            isTotal: true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(
                      cartItems: _dummyCartItems,
                      subtotal: _totalAmount,
                      shippingFee: 15000,
                      total: _totalAmount + 15000,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Tiến hành thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppTheme.primaryColor : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppTheme.secondaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}