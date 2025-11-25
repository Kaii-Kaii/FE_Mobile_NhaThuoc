import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_nha_thuoc/models/invoice_detail_model.dart';
import 'package:quan_ly_nha_thuoc/services/order_service.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  final OrderService _orderService = OrderService();
  late Future<InvoiceDetailResponse> _invoiceDetailFuture;

  @override
  void initState() {
    super.initState();
    _invoiceDetailFuture = _orderService.getInvoiceDetail(widget.invoiceId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Chi tiết hóa đơn',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF03A297),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<InvoiceDetailResponse>(
        future: _invoiceDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final invoice = data.invoice;
          final summary = data.summary;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with gradient
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF03A297), Color(0xFF02756B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        invoice.maHD,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: _getStatusColor(invoice.trangThaiGiaoHang),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              invoice.trangThaiGiaoHangName,
                              style: TextStyle(
                                color: _getStatusColor(
                                  invoice.trangThaiGiaoHang,
                                ),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Invoice Info Card
                      _buildInfoCard(
                        title: 'Thông tin hóa đơn',
                        icon: Icons.receipt_long,
                        children: [
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Ngày lập',
                            DateFormat('dd/MM/yyyy').format(invoice.ngayLap),
                          ),
                          if (invoice.ghiChu != null &&
                              invoice.ghiChu!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.note,
                              'Ghi chú',
                              invoice.ghiChu!,
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Customer Info Card
                      _buildInfoCard(
                        title: 'Thông tin khách hàng',
                        icon: Icons.person,
                        children: [
                          _buildInfoRow(Icons.badge, 'Mã KH', invoice.maKH),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.person_outline,
                            'Tên KH',
                            invoice.tenKH,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.location_on,
                            'Địa chỉ',
                            invoice.diaChiKH,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.phone,
                            'Điện thoại',
                            invoice.dienThoaiKH,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Employee Info Card
                      _buildInfoCard(
                        title: 'Nhân viên phụ trách',
                        icon: Icons.support_agent,
                        children: [
                          _buildInfoRow(
                            Icons.badge_outlined,
                            'Mã NV',
                            invoice.maNV,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.person_outline,
                            'Tên NV',
                            invoice.tenNV,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Products Section
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF03A297,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.medical_services,
                                      color: Color(0xFF03A297),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Danh sách sản phẩm',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: summary.length,
                              separatorBuilder:
                                  (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = summary[index];
                                return _buildProductItem(item);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Total Amount Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF03A297), Color(0xFF02756B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF03A297).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              'TỔNG TIỀN',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${NumberFormat('#,###').format(invoice.tongTien)} đ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF03A297).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF03A297), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(InvoiceSummaryItemModel item) {
    final now = DateTime.now();
    final daysUntilExpiry =
        item.hanSuDungGanNhat?.difference(now).inDays ?? 999;
    final isExpiringSoon = daysUntilExpiry <= 90 && daysUntilExpiry > 0;
    final isExpired = daysUntilExpiry <= 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF03A297).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medication,
                  color: Color(0xFF03A297),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.tenThuoc,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mã: ${item.maThuoc}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Số lượng',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    Text(
                      '${item.tongSoLuong} ${item.tenLoaiDonVi}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đơn giá',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    Text(
                      '${NumberFormat('#,###').format(item.donGiaTrungBinh)} đ',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thành tiền',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${NumberFormat('#,###').format(item.tongThanhTien)} đ',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF03A297),
                      ),
                    ),
                  ],
                ),
                if (item.hanSuDungGanNhat != null) ...[
                  const Divider(height: 20),
                  Row(
                    children: [
                      Icon(
                        isExpired
                            ? Icons.warning
                            : isExpiringSoon
                            ? Icons.access_time
                            : Icons.calendar_today,
                        size: 16,
                        color:
                            isExpired
                                ? Colors.red
                                : isExpiringSoon
                                ? Colors.orange
                                : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'HSD: ${DateFormat('dd/MM/yyyy').format(item.hanSuDungGanNhat!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isExpired
                                  ? Colors.red
                                  : isExpiringSoon
                                  ? Colors.orange
                                  : Colors.grey[600],
                          fontWeight:
                              isExpired || isExpiringSoon
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                      if (isExpiringSoon && !isExpired) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Text(
                            'Sắp hết hạn',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      if (isExpired) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.red),
                          ),
                          child: const Text(
                            'Hết hạn',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
