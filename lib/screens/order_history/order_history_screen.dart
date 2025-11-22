import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_nha_thuoc/models/order_history_model.dart';
import 'package:quan_ly_nha_thuoc/providers/customer_provider.dart';
import 'package:quan_ly_nha_thuoc/services/order_service.dart';
import 'package:quan_ly_nha_thuoc/screens/home/account_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/order_history/invoice_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => OrderHistoryScreenState();
}

class OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderService _orderService = OrderService();
  late Future<List<OrderHistoryModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void refresh() {
    setState(() {
      _loadHistory();
    });
  }

  void _loadHistory() {
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );
    final customerId = customerProvider.customer?.maKH ?? '';
    if (customerId.isNotEmpty) {
      _historyFuture = _orderService.getHistoryByCustomer(customerId);
    } else {
      _historyFuture = Future.value([]);
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case -1:
        return Colors.red;
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOrderList(List<OrderHistoryModel> allOrders, int status) {
    final filteredOrders =
        allOrders.where((o) => o.trangThaiGiaoHang == status).toList();

    if (filteredOrders.isEmpty) {
      return const Center(child: Text('Không có đơn hàng nào.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => InvoiceDetailScreen(invoiceId: order.maHD),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.maHD,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            order.trangThaiGiaoHang,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getStatusColor(order.trangThaiGiaoHang),
                          ),
                        ),
                        child: Text(
                          order.trangThaiGiaoHangName,
                          style: TextStyle(
                            color: _getStatusColor(order.trangThaiGiaoHang),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd/MM/yyyy').format(order.ngayLap),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${NumberFormat('#,###').format(order.tongTien)} đ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF03A297),
                        ),
                      ),
                    ],
                  ),
                  if (order.ghiChu != null && order.ghiChu!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.ghiChu!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Lịch sử đơn hàng',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF03A297),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Hủy'),
              Tab(text: 'Đã đặt'),
              Tab(text: 'Đã xác nhận'),
              Tab(text: 'Đã giao'),
              Tab(text: 'Hoàn thành'),
            ],
          ),
        ),
        body: FutureBuilder<List<OrderHistoryModel>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            }

            final orders = snapshot.data ?? [];

            return TabBarView(
              children: [
                _buildOrderList(orders, -1),
                _buildOrderList(orders, 0),
                _buildOrderList(orders, 1),
                _buildOrderList(orders, 2),
                _buildOrderList(orders, 3),
              ],
            );
          },
        ),
      ),
    );
  }
}
