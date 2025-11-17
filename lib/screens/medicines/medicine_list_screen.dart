import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:quan_ly_nha_thuoc/providers/cart_provider.dart';
import '../../models/medicine_by_type.dart';
import '../../services/thuoc_service.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/network_image_cert.dart';
import 'cart_screen.dart';
import 'medicine_detail_screen.dart';

class MedicineListScreen extends StatefulWidget {
  final String? maLoaiThuoc;
  final String? title;

  const MedicineListScreen({Key? key, this.maLoaiThuoc, this.title})
    : super(key: key);
  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  final ThuocService _service = ThuocService();
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _priceFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
  );

  bool _loading = true;
  String? _error;
  List<MedicineByType> _medicines = [];
  List<MedicineByType> _filteredMedicines = [];

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMedicines() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final meds =
          widget.maLoaiThuoc != null
              ? await _service.getByLoai(widget.maLoaiThuoc!)
              : await _service.getAll();

      setState(() {
        _medicines = meds;
        _filteredMedicines = meds;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Lỗi tải danh sách: $e';
      });
    }
  }

  void _filter() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredMedicines = _medicines;
      } else {
        _filteredMedicines =
            _medicines.where((m) {
              return m.tenThuoc.toLowerCase().contains(q) ||
                  (m.moTa?.toLowerCase().contains(q) ?? false) ||
                  (m.tenNCC?.toLowerCase().contains(q) ?? false);
            }).toList();
      }
    });
  }

  // Hàm xử lý ảnh
  Widget buildMedicineImage(String? url) {
    if (url == null || url.trim().isEmpty) return _brokenImage();

    final source = url.trim();
    final isAbsolute =
        source.startsWith('http://') || source.startsWith('https://');
    final imageUrl =
        isAbsolute
            ? source
            : 'https://res.cloudinary.com/dmu0nknhg/image/upload/v1761064479/thuoc_images/thuoc/$source';

    return NetworkImageWithCertHandling(imageUrl: imageUrl, fit: BoxFit.cover);
  }

  Widget _brokenImage() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.title ?? "Danh sách thuốc"),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, __) {
              final count = cart.items.length;
              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    if (count > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                tooltip: 'Giỏ hàng',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [_buildSearchBar(), Expanded(child: _buildBody())],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppTheme.primaryColor,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: "Tìm kiếm thuốc...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_filteredMedicines.isEmpty) {
      return const Center(child: Text("Không tìm thấy thuốc"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.64,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredMedicines.length,
      itemBuilder: (_, i) {
        return _MedicineCard(
          medicine: _filteredMedicines[i],
          priceFormatter: _priceFormatter,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => MedicineDetailScreen(
                      maThuoc: _filteredMedicines[i].maThuoc,
                    ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MedicineCard extends StatefulWidget {
  final MedicineByType medicine;
  final NumberFormat priceFormatter;
  final VoidCallback onTap;

  const _MedicineCard({
    required this.medicine,
    required this.priceFormatter,
    required this.onTap,
  });

  @override
  State<_MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<_MedicineCard> {
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _selected = widget.medicine.giaThuocs.indexWhere((o) => o.soLuongCon > 0);
    if (_selected < 0) _selected = 0;
  }

  Widget buildMedicineImage(String? url) {
    if (url == null || url.trim().isEmpty) return _brokenImage();

    final source = url.trim();
    final isAbsolute =
        source.startsWith('http://') || source.startsWith('https://');
    final imageUrl =
        isAbsolute
            ? source
            : 'https://res.cloudinary.com/dmu0nknhg/image/upload/v1761064479/thuoc_images/thuoc/$source';

    return NetworkImageWithCertHandling(imageUrl: imageUrl, fit: BoxFit.cover);
  }

  Widget _brokenImage() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    final option =
        widget.medicine.giaThuocs.isEmpty
            ? null
            : widget.medicine.giaThuocs[_selected];

    final price = option?.donGia ?? widget.medicine.donGiaSi ?? 0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: buildMedicineImage(widget.medicine.urlAnh),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.medicine.tenThuoc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.medicine.tenNCC ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  if (widget.medicine.giaThuocs.isNotEmpty)
                    SizedBox(
                      height: 32,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.medicine.giaThuocs.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 4),
                        itemBuilder: (_, i) {
                          final optionLabel =
                              widget.medicine.giaThuocs[i].tenLoaiDonVi;
                          return ChoiceChip(
                            label: Text(
                              optionLabel,
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: _selected == i,
                            onSelected: (v) {
                              if (v) setState(() => _selected = i);
                            },
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${widget.priceFormatter.format(price)} đ",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final cart = context.read<CartProvider>();
                          cart.addMedicine(
                            medicine: widget.medicine,
                            option: option,
                            quantity: 1,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Đã thêm ${widget.medicine.tenThuoc}",
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
