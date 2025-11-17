import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/thuoc_service.dart';
import '../../models/medicine_detail.dart';
import '../../models/medicine_price_option.dart';
import '../../providers/cart_provider.dart';

class MedicineDetailScreen extends StatefulWidget {
  final String maThuoc;

  const MedicineDetailScreen({super.key, required this.maThuoc});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  final ThuocService _service = ThuocService();
  final NumberFormat _fmt = NumberFormat.decimalPattern('vi_VN');

  MedicineDetail? _detail;
  bool _loading = true;
  String? _error;

  int _selectedIndex = 0;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() => _loading = true);

      final d = await _service.getById(widget.maThuoc);

      if (d.giaThuocs.isNotEmpty) {
        final idx = d.giaThuocs.indexWhere((e) => (e.soLuongCon ?? 0) > 0);
        _selectedIndex = idx >= 0 ? idx : 0;
      }

      setState(() {
        _detail = d;
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text("Lỗi: $_error")));
    }

    final d = _detail!;
    final opts = d.giaThuocs;

    final MedicinePriceOption? selected =
        opts.isNotEmpty ? opts[_selectedIndex] : null;

    final price = selected?.donGia ?? 0;
    final stock = (selected?.soLuongCon ?? 0).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF023350),
        title: Text(d.tenThuoc),
      ),
      body: Column(
        children: [
          _buildHeader(d),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildDetailBody(d),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottom(price, stock, selected),
    );
  }

  // ---------------- HEADER ------------------
  Widget _buildHeader(MedicineDetail d) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF023350),
      child: Row(
        children: [
          _buildImage(d),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.tenThuoc,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (d.tenNCC != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    d.tenNCC!,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
                if (d.giaThuocs.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildUnitSelector(d.giaThuocs),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(MedicineDetail d) {
    final img = d.urlAnh;
    final url =
        (img != null && img.startsWith("http"))
            ? img
            : "https://res.cloudinary.com/dmu0nknhg/image/upload/v1761064479/thuoc_images/thuoc/$img";

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
      ),
      clipBehavior: Clip.hardEdge,
      child:
          img == null || img.isEmpty
              ? const Icon(Icons.medication, size: 60, color: Colors.teal)
              : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => const Icon(Icons.broken_image, size: 60),
              ),
    );
  }

  // -------- UNIT SELECTOR ----------
  Widget _buildUnitSelector(List<MedicinePriceOption> options) {
    if (options.length == 1) {
      return _chipSingle(options.first.tenLoaiDonVi);
    }

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: options.length,
        itemBuilder: (_, i) {
          final op = options[i];
          final selected = i == _selectedIndex;

          return ChoiceChip(
            label: Text(op.tenLoaiDonVi),
            selected: selected,
            selectedColor: Colors.white,
            backgroundColor: Colors.white24,
            labelStyle: TextStyle(
              color: selected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
            onSelected: (_) => setState(() => _selectedIndex = i),
          );
        },
      ),
    );
  }

  Widget _chipSingle(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  // -------- DETAILS --------
  Widget _buildDetailBody(MedicineDetail d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section("Mô tả", d.moTa),
        _section("Thành phần", d.thanhPhan),
        _section("Công dụng", d.congDung),
        _section("Cách dùng", d.cachDung),
        _section("Lưu ý", d.luuY),
      ],
    );
  }

  Widget _section(String title, String? content) {
    if (content == null || content.trim().isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(content),
        ],
      ),
    );
  }

  // -------- BOTTOM BAR ---------
  Widget _buildBottom(num price, int stock, MedicinePriceOption? option) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "${_fmt.format(price)} đ / ${option?.tenLoaiDonVi ?? ''}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                ),
                Text("$_qty", style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _qty++),
                ),
              ],
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              onPressed:
                  option == null
                      ? null
                      : () {
                        final mapped = _detail!.toByType();

                        context.read<CartProvider>().addMedicine(
                          medicine: mapped,
                          option: option,
                          quantity: _qty,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Đã thêm ${mapped.tenThuoc} (${option.tenLoaiDonVi}) x$_qty",
                            ),
                          ),
                        );
                      },
              child: const Text(
                "Thêm vào giỏ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
