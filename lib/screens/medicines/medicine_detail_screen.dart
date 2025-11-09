import 'package:flutter/material.dart';
import '../../services/thuoc_service.dart';
import '../../models/medicine_detail.dart';

class MedicineDetailScreen extends StatefulWidget {
  final String maThuoc;
  const MedicineDetailScreen({Key? key, required this.maThuoc}) : super(key: key);

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  final ThuocService _service = ThuocService();
  bool _loading = true;
  String? _error;
  MedicineDetail? _detail;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      debugPrint('MedicineDetailScreen: fetching maThuoc=${widget.maThuoc}');
      final d = await _service.getById(widget.maThuoc);
      debugPrint('MedicineDetailScreen: fetched detail for ${d.maThuoc}');
      setState(() { _detail = d; _loading = false; });
    } catch (e, st) {
      debugPrint('MedicineDetailScreen: error fetching detail: $e\n$st');
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (_loading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (_error != null) {
        return Scaffold(body: Center(child: Text('Lỗi: $_error')));
      }
      if (_detail == null) {
        return Scaffold(body: Center(child: Text('Không tìm thấy dữ liệu')));
      }

      final d = _detail!;

      return Scaffold(
        backgroundColor: const Color(0xFFF3F6F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFF023350),
          title: Text(d.tenThuoc, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        body: Column(
          children: [
            // Top info section with image
            Container(
              width: double.infinity,
              color: const Color(0xFF023350),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              child: Row(
                children: [
                  // Product image
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white),
                    child: _buildProductImage(d),
                  ),
                  const SizedBox(width: 12),
                  // Title + brief info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          d.tenThuoc,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          d.tenLoaiDonVi ?? 'N/A',
                          style: const TextStyle(color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${d.donGiaSi ?? 0} đ',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable details section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (d.moTa != null && d.moTa!.isNotEmpty) ...[
                      const Text('Mô tả', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(d.moTa!),
                      const SizedBox(height: 12),
                    ],

                    if (d.thanhPhan != null && d.thanhPhan!.isNotEmpty) ...[
                      const Text('Thành phần', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._buildBulletList(d.thanhPhan!),
                      const SizedBox(height: 12),
                    ],

                    if (d.congDung != null && d.congDung!.isNotEmpty) ...[
                      const Text('Công dụng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(d.congDung!),
                      const SizedBox(height: 12),
                    ],

                    if (d.cachDung != null && d.cachDung!.isNotEmpty) ...[
                      const Text('Cách dùng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(d.cachDung!),
                      const SizedBox(height: 12),
                    ],

                    if (d.luuY != null && d.luuY!.isNotEmpty) ...[
                      const Text('Lưu ý', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(d.luuY!),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Price and supplier
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${d.donGiaSi ?? 0} đ',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        d.tenNCC ?? 'N/A',
                        style: const TextStyle(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Quantity controls
                SizedBox(
                  width: 110,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_qty > 1) setState(() { _qty--; });
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        iconSize: 20,
                      ),
                      Text('$_qty', style: const TextStyle(fontSize: 16)),
                      IconButton(
                        onPressed: () {
                          setState(() { _qty++; });
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        iconSize: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Buy button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint('Buy button tapped: quantity=$_qty');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('MedicineDetailScreen build error: $e\n$st');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 56),
              const SizedBox(height: 16),
              const Text('UI Rendering Error'),
              const SizedBox(height: 8),
              Text(e.toString(), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildProductImage(MedicineDetail d) {
    if (d.urlAnh == null || d.urlAnh!.isEmpty) {
      return const Icon(Icons.medication, size: 56, color: Color(0xFF03A297));
    }

    final imageUrl = 'https://res.cloudinary.com/dmu0nknhg/image/upload/v1761064479/thuoc_images/thuoc/${d.urlAnh}';

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Image load error for ${d.urlAnh}: $error');
        return const Icon(Icons.medication, size: 56, color: Color(0xFF03A297));
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }

  List<Widget> _buildBulletList(String text) {
    final parts = text.split(RegExp(r'\r?\n')).where((s) => s.trim().isNotEmpty).toList();
    return parts
        .map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 14)),
                  Expanded(child: Text(p)),
                ],
              ),
            ))
        .toList();
  }
}