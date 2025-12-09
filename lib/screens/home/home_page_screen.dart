import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/customer_provider.dart';

import 'package:quan_ly_nha_thuoc/models/categoryGroup/CategoryGroup.dart';
import 'package:quan_ly_nha_thuoc/models/categoryGroup/CategoryGroup_service.dart';
import 'package:quan_ly_nha_thuoc/services/thuoc_service.dart';
import 'package:quan_ly_nha_thuoc/models/medicine_by_type.dart';
import 'package:quan_ly_nha_thuoc/utils/icon_generator.dart';
import '../medicines/medicine_detail_screen.dart';
import '../medicines/medicine_list_screen.dart';
import '../main_screen.dart';
import '../../theme/app_theme.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final CategoryGroupService _categoryService = CategoryGroupService();
  final ThuocService _medicineService = ThuocService();
  List<CategoryGroup> _categories = [];
  List<MedicineByType> _featuredMedicines = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final groups = await _categoryService.getAllCategoryGroups();
      final medicines = await _medicineService.getAll();

      if (!mounted) return;

      setState(() {
        _categories = groups;
        _featuredMedicines = medicines.take(10).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 20),
                    children: [
                      _buildHeader(),
                      _buildDynamicCategories(),
                      _buildDynamicProducts(),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        children: [
          // Logo và icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo và tên
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.secondaryColor,
                          AppTheme.secondaryColor.withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.secondaryColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.local_pharmacy,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NHÀ THUỐC',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'AN KHANG',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Buttons
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Phần tìm kiếm
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: AppTheme.secondaryColor,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => MedicineListScreen(
                                        title: "Kết quả tìm kiếm",
                                        searchQuery: value.trim(),
                                      ),
                                ),
                              );
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm thuốc, sản phẩm...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Thông tin vị trí
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Consumer<CustomerProvider>(
                  builder: (context, customerProvider, child) {
                    final hour = DateTime.now().hour;
                    String greeting;
                    if (hour >= 5 && hour < 12) {
                      greeting = 'Chào buổi sáng';
                    } else if (hour >= 12 && hour < 14) {
                      greeting = 'Chào buổi trưa';
                    } else if (hour >= 14 && hour < 18) {
                      greeting = 'Chào buổi chiều';
                    } else {
                      greeting = 'Chào buổi tối';
                    }

                    final name = customerProvider.customer?.hoTen;
                    if (name != null && name.isNotEmpty) {
                      greeting += ', $name';
                    }

                    return Text(
                      greeting,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicCategories() {
    if (_categories.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Danh mục nổi bật',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  MainScreen.of(context)?.navigateToCategory(null);
                },
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(color: AppTheme.secondaryColor),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return GestureDetector(
                onTap: () {
                  MainScreen.of(context)?.navigateToCategory(cat.maNhomLoai);
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          IconGenerator.getIconForMedicineType(cat.tenNhomLoai),
                          color: AppTheme.secondaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.tenNhomLoai,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicProducts() {
    if (_featuredMedicines.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Sản phẩm nổi bật',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => const MedicineListScreen(
                            title: "Tất cả sản phẩm",
                          ),
                    ),
                  );
                },
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(color: AppTheme.secondaryColor),
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _featuredMedicines.length,
          itemBuilder: (context, index) {
            final medicine = _featuredMedicines[index];
            return _buildProductCard(medicine);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(MedicineByType medicine) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MedicineDetailScreen(maThuoc: medicine.maThuoc),
          ),
        );
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child:
                    medicine.urlAnh != null && medicine.urlAnh!.isNotEmpty
                        ? Image.network(
                          medicine.urlAnh!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                color: Colors.grey[100],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                        )
                        : Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: Icon(
                              Icons.medication,
                              color: AppTheme.secondaryColor,
                              size: 40,
                            ),
                          ),
                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.tenThuoc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medicine.giaThuocs.isNotEmpty
                        ? '${NumberFormat("#,###", "vi_VN").format(medicine.giaThuocs.first.donGia)} đ'
                        : 'Liên hệ',
                    style: const TextStyle(
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => MedicineDetailScreen(
                                  maThuoc: medicine.maThuoc,
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Thêm vào giỏ',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
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
