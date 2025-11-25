import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/thuoc_service.dart';
import '../../models/medicine_detail.dart';
import '../../models/medicine_price_option.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/snackbar_helper.dart';

class MedicineDetailScreen extends StatefulWidget {
  final String maThuoc;

  const MedicineDetailScreen({super.key, required this.maThuoc});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  final ThuocService _service = ThuocService();
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
    decimalDigits: 0,
  );

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
        final idx = d.giaThuocs.indexWhere((e) => e.soLuongCon > 0);
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
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          d.tenThuoc,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 320,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor,
                  Colors.transparent,
                ],
                stops: [0, 0.6, 1],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroHeader(d, selected, stock),
                        const SizedBox(height: 24),
                        _buildDetailBody(d),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottom(price, stock, selected),
    );
  }

  // ---------------- HEADER ------------------
  Widget _buildHeroHeader(
    MedicineDetail detail,
    MedicinePriceOption? selected,
    int stock,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(detail),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.tenThuoc,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      if (detail.tenNCC?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified_outlined,
                                size: 18,
                                color: AppTheme.secondaryColor,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  detail.tenNCC!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (detail.giaThuocs.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _buildUnitSelector(detail.giaThuocs),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (selected != null)
                  _infoBadge(
                    icon: Icons.stacked_bar_chart_outlined,
                    label: 'Quy cách',
                    value: _formatQuantity(selected.soLuong),
                  ),
                _infoBadge(
                  icon: Icons.inventory_2_outlined,
                  label: 'Tồn kho',
                  value:
                      stock > 0
                          ? '$stock ${selected?.tenLoaiDonVi.toLowerCase() ?? 'đv'}'
                          : 'Tạm hết hàng',
                  highlight: stock <= 0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(MedicineDetail d) {
    final img = d.urlAnh;
    final url =
        (img != null && img.startsWith("http"))
            ? img
            : "https://res.cloudinary.com/dmu0nknhg/image/upload/v1761064479/thuoc_images/thuoc/$img";

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryColor.withOpacity(0.08), Colors.white],
          ),
        ),
        child:
            img == null || img.isEmpty
                ? Icon(
                  Icons.medication_liquid_outlined,
                  size: 54,
                  color: AppTheme.secondaryColor,
                )
                : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Icon(
                        Icons.broken_image_outlined,
                        size: 48,
                        color: Colors.grey[500],
                      ),
                ),
      ),
    );
  }

  // -------- UNIT SELECTOR ----------
  Widget _buildUnitSelector(List<MedicinePriceOption> options) {
    if (options.length == 1) {
      return _chipSingle(options.first.tenLoaiDonVi);
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(options.length, (i) {
        final op = options[i];
        final selected = i == _selectedIndex;

        return ChoiceChip(
          label: Text(op.tenLoaiDonVi),
          selected: selected,
          backgroundColor: Colors.grey[200],
          selectedColor: AppTheme.primaryColor,
          labelStyle: TextStyle(
            color: selected ? Colors.white : AppTheme.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color:
                  selected
                      ? AppTheme.primaryColor
                      : Colors.grey.withOpacity(0.25),
            ),
          ),
          onSelected: (_) => setState(() => _selectedIndex = i),
        );
      }),
    );
  }

  Widget _chipSingle(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // -------- DETAILS --------
  Widget _buildDetailBody(MedicineDetail d) {
    final sections = [
      {'title': 'Mô tả', 'content': d.moTa, 'icon': Icons.menu_book_outlined},
      {
        'title': 'Thành phần',
        'content': d.thanhPhan,
        'icon': Icons.science_outlined,
      },
      {
        'title': 'Công dụng',
        'content': d.congDung,
        'icon': Icons.health_and_safety_outlined,
      },
      {
        'title': 'Cách dùng',
        'content': d.cachDung,
        'icon': Icons.medical_services_outlined,
      },
      {'title': 'Lưu ý', 'content': d.luuY, 'icon': Icons.info_outline},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          sections
              .where(
                (s) => (s['content'] as String?)?.trim().isNotEmpty ?? false,
              )
              .map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: ExpandableDetailCard(
                    title: s['title'] as String,
                    content: s['content'] as String,
                    icon: s['icon'] as IconData,
                  ),
                ),
              )
              .toList(),
    );
  }

  // -------- BOTTOM BAR ---------
  Widget _buildBottom(num price, int stock, MedicinePriceOption? option) {
    final isOutOfStock = stock <= 0;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giá hiện tại',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option == null
                            ? 'Chưa có thông tin giá'
                            : '${_formatCurrency(price)} / ${option.tenLoaiDonVi}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color:
                              isOutOfStock
                                  ? Colors.grey[500]
                                  : AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (option != null)
                  Text(
                    'Còn lại: $stock',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          isOutOfStock
                              ? AppTheme.errorColor
                              : AppTheme.textSecondaryColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _quantityStepper(enabled: option != null && !isOutOfStock),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isOutOfStock
                              ? Colors.grey[300]
                              : AppTheme.secondaryColor,
                      foregroundColor:
                          isOutOfStock ? Colors.grey[700] : Colors.white,
                      elevation: isOutOfStock ? 0 : 4,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed:
                        (option == null || isOutOfStock)
                            ? null
                            : () {
                              final mapped = _detail!.toByType();

                              context.read<CartProvider>().addMedicine(
                                medicine: mapped,
                                option: option,
                                quantity: _qty,
                              );

                              SnackBarHelper.show(
                                context,
                                'Đã thêm ${mapped.tenThuoc} (${option.tenLoaiDonVi}) x$_qty',
                                type: SnackBarType.success,
                              );
                            },
                    child: Text(
                      isOutOfStock ? 'Tạm hết hàng' : 'Thêm vào giỏ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityStepper({required bool enabled}) {
    return Container(
      decoration: BoxDecoration(
        color:
            enabled
                ? AppTheme.primaryColor.withOpacity(0.08)
                : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _stepperButton(
            icon: Icons.remove_rounded,
            onTap: enabled && _qty > 1 ? () => setState(() => _qty--) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              '$_qty',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          _stepperButton(
            icon: Icons.add_rounded,
            onTap: enabled ? () => setState(() => _qty++) : null,
          ),
        ],
      ),
    );
  }

  Widget _stepperButton({required IconData icon, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: onTap == null ? Colors.grey[400] : AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _infoBadge({
    required IconData icon,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:
            highlight
                ? AppTheme.errorColor.withOpacity(0.12)
                : AppTheme.primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: highlight ? AppTheme.errorColor : AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color:
                      highlight
                          ? AppTheme.errorColor
                          : AppTheme.textSecondaryColor,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color:
                      highlight
                          ? AppTheme.errorColor
                          : AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatQuantity(double value) {
    final isInt = value % 1 == 0;
    return isInt ? value.toInt().toString() : value.toStringAsFixed(1);
  }

  String _formatCurrency(num value) {
    return '${_currencyFormatter.format(value).trim()} đ';
  }
}

class ExpandableDetailCard extends StatefulWidget {
  final String title;
  final String content;
  final IconData icon;

  const ExpandableDetailCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  State<ExpandableDetailCard> createState() => _ExpandableDetailCardState();
}

class _ExpandableDetailCardState extends State<ExpandableDetailCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.icon,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    width: double.infinity,
                    child:
                        _isExpanded
                            ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                widget.content,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            )
                            : null,
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
