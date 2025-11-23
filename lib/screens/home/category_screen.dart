import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_nha_thuoc/providers/cart_provider.dart';
import '../medicines/cart_screen.dart';
import 'package:quan_ly_nha_thuoc/models/categoryGroup/CategoryGroup.dart';
import 'package:quan_ly_nha_thuoc/models/categoryGroup/CategoryGroup_service.dart';
import 'package:quan_ly_nha_thuoc/models/categoryGroup/CategoryType.dart';
import 'package:quan_ly_nha_thuoc/utils/icon_generator.dart';
import '../medicines/medicines_by_type_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // leftCategories now include id and title: {'id': maNhomLoai, 'title': tenNhomLoai}
  final List<Map<String, String>> _leftCategories = [];
  final List<String> _groupIds = [];
  final CategoryGroupService _service = CategoryGroupService();
  bool _loadingLeft = true;
  String? _errorMessage;
  // Types for selected group
  List<CategoryType> _types = [];
  bool _loadingTypes = false;
  String? _typesError;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _loadingLeft = true;
      _errorMessage = null;
    });

    try {
      final List<CategoryGroup> groups = await _service.getAllCategoryGroups();
      setState(() {
        _leftCategories.clear();
        _groupIds.clear();
        for (final g in groups) {
          // store id separately so we can reliably access it by index
          _groupIds.add(g.maNhomLoai);
          // also keep id in the leftCategories map so fallback works if needed
          _leftCategories.add({'id': g.maNhomLoai, 'title': g.tenNhomLoai});
        }
        // debug
        print('Loaded groups (${groups.length}): ${_groupIds}');
        print('Left categories: ${_leftCategories}');
        _loadingLeft = false;
      });

      // Auto-load types for first group if exists.
      // Use _groupIds[0] directly to avoid any timing/fallback issue where the map
      // entry might not yet contain 'id' when _onSelectGroup reads it.
      if (_groupIds.isNotEmpty) {
        final firstId = _groupIds[0];
        print('Auto-loading types for first group id=$firstId');
        setState(() {
          _selectedIndex = 0;
          _types = [];
          _typesError = null;
          _loadingTypes = true;
        });
        if (firstId.isNotEmpty) {
          _loadTypes(firstId);
        } else {
          setState(() {
            _loadingTypes = false;
            _typesError = 'Invalid group id';
          });
        }
      } else if (_leftCategories.isNotEmpty) {
        // Fallback to map-based selection if groupIds wasn't populated for some reason
        _onSelectGroup(0);
      }
    } catch (e) {
      setState(() {
        _loadingLeft = false;
        _errorMessage = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lấy dữ liệu: $_errorMessage')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Subtle light gray background so tiles remain bright but page is not pure white
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // Top search row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Back button removed as this is a main tab
                  // IconButton(
                  //   onPressed: () => Navigator.of(context).maybePop(),
                  //   icon: const Icon(Icons.arrow_back_ios, size: 20),
                  // ),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tìm kiếm',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt_outlined),
                  ),
                  Consumer<CartProvider>(
                    builder:
                        (_, cart, __) => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CartScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.shopping_bag_outlined),
                            ),
                            if (cart.items.isNotEmpty)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${cart.items.length}',
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
                  ),
                ],
              ),
            ),

            Expanded(
              child: Row(
                children: [
                  // Left vertical categories (from API) — take 2/7 of width
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.transparent,
                      child: _buildLeftContent(),
                    ),
                  ),

                  // Right content — take 5/7 of width
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Content area: list of types for selected group
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            color: Colors.transparent,
                            child:
                                _loadingTypes
                                    ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                    : _typesError != null
                                    ? Center(child: Text('Lỗi: $_typesError'))
                                    : LayoutBuilder(
                                      builder: (context, constraints) {
                                        // Add bottom padding to account for bottom navigation, FAB and safe area.
                                        final mq = MediaQuery.of(context);
                                        final safeBottom = mq.padding.bottom;
                                        final bottomInset =
                                            safeBottom +
                                            kBottomNavigationBarHeight +
                                            80;

                                        // Compute tile aspect ratio so each tile fits without overflow.
                                        const crossAxisCount = 3;
                                        const spacing = 12.0;
                                        final totalSpacing =
                                            spacing * (crossAxisCount - 1);
                                        final tileWidth =
                                            (constraints.maxWidth -
                                                totalSpacing) /
                                            crossAxisCount;
                                        // Desired tile height: icon (64) + spacing (6) + text box (36) + padding allowance (10)
                                        const tileHeight =
                                            64.0 + 6.0 + 36.0 + 10.0;
                                        final childAspectRatio =
                                            tileWidth / tileHeight;

                                        return GridView.builder(
                                          padding: EdgeInsets.only(
                                            top: 8,
                                            left: 0,
                                            right: 0,
                                            bottom: bottomInset,
                                          ),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: crossAxisCount,
                                                childAspectRatio:
                                                    childAspectRatio,
                                                crossAxisSpacing: spacing,
                                                mainAxisSpacing: spacing,
                                              ),
                                          itemCount: _types.length,
                                          itemBuilder: (context, i) {
                                            final t = _types[i];
                                            return Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                onTap: () {
                                                  // Navigate to medicines-by-type screen
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            _,
                                                          ) => MedicinesByTypeScreen(
                                                            maLoai:
                                                                t.maLoaiThuoc,
                                                            tenLoai:
                                                                t.tenLoaiThuoc,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 64,
                                                      height: 64,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                  0.04,
                                                                ),
                                                            blurRadius: 6,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  2,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Center(
                                                        child: Icon(
                                                          IconGenerator.getIconForMedicineType(
                                                            t.tenLoaiThuoc,
                                                          ),
                                                          size: 40,
                                                          color:
                                                              IconGenerator.getColorForMedicineType(
                                                                t.tenLoaiThuoc,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    SizedBox(
                                                      height: 36,
                                                      child: Center(
                                                        child: Text(
                                                          t.tenLoaiThuoc,
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 2,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          softWrap: true,
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                          ),
                        ),
                      ],
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

  Widget _buildLeftContent() {
    if (_loadingLeft) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8),
            const Text('Lỗi', style: TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchCategories,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _leftCategories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _leftCategories[index];
        final selected = index == _selectedIndex;
        return InkWell(
          onTap: () => _onSelectGroup(index),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
              border:
                  selected
                      ? Border.all(color: const Color(0xFF03A297), width: 1.6)
                      : null,
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                item['title'] ?? '',
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.visible,
                softWrap: true,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? const Color(0xFF03A297) : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onSelectGroup(int index) {
    final item = _leftCategories[index];
    // Prefer stored id list; fallback to map value if present
    final id =
        (index < _groupIds.length && _groupIds[index].isNotEmpty)
            ? _groupIds[index]
            : (item['id']);
    // debug
    print('Selecting group index=$index id=$id title=${item['title']}');
    setState(() {
      _selectedIndex = index;
      _types = [];
      _typesError = null;
      _loadingTypes = true;
    });
    if (id != null && id.isNotEmpty) {
      _loadTypes(id);
    } else {
      setState(() {
        _loadingTypes = false;
        _typesError = 'Invalid group id';
      });
    }
  }

  Future<void> _loadTypes(String maNhomLoai) async {
    try {
      print('Loading types for group: $maNhomLoai');
      final types = await _service.getTypesByGroup(maNhomLoai);
      setState(() {
        _types = types;
        print('Loaded types count: ${types.length}');
        _loadingTypes = false;
      });
    } catch (e) {
      setState(() {
        _typesError = e.toString();
        _loadingTypes = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lấy loại: $_typesError')),
        );
      }
    }
  }

  // Bottom nav is extracted to AppBottomNavBar widget
}
