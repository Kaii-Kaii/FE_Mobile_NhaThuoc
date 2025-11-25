import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/thuoc_service.dart';
import '../../models/medicine_by_type.dart';
import 'medicine_detail_screen.dart';
import '../../widgets/network_image_cert.dart';

class MedicinesByTypeScreen extends StatefulWidget {
  final String maLoai;
  final String tenLoai;
  const MedicinesByTypeScreen({
    super.key,
    required this.maLoai,
    required this.tenLoai,
  });

  @override
  State<MedicinesByTypeScreen> createState() => _MedicinesByTypeScreenState();
}

class _MedicinesByTypeScreenState extends State<MedicinesByTypeScreen> {
  final ThuocService _service = ThuocService();
  bool _loading = true;
  String? _error;
  List<MedicineByType> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.getByLoai(widget.maLoai);
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.tenLoai),
        backgroundColor: const Color(0xFF023350),
        elevation: 0,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Lỗi: $_error'))
              : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  return _buildMedicineItem(_items[i]);
                },
              ),
    );
  }

  Widget _buildMedicineItem(MedicineByType m) {
    final priceFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final price =
        m.giaThuocs.isNotEmpty ? m.giaThuocs.first.donGia : (m.donGiaSi ?? 0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MedicineDetailScreen(maThuoc: m.maThuoc),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[100]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        (m.urlAnh != null && m.urlAnh!.isNotEmpty)
                            ? Builder(
                              builder: (_) {
                                final s = m.urlAnh!.trim();
                                final imageUrl =
                                    (s.startsWith('http://') ||
                                            s.startsWith('https://'))
                                        ? s
                                        : 'https://res.cloudinary.com/dmu0nknhg/image/upload/v1761064479/thuoc_images/thuoc/$s';
                                return NetworkImageWithCertHandling(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                            : const Icon(
                              Icons.medication,
                              color: Color(0xFF03A297),
                              size: 32,
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              m.tenThuoc,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            priceFormatter.format(price),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        m.tenNCC ?? 'Đang cập nhật',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Optional: Add tags or stock status here if needed
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Còn hàng',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF00695C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
