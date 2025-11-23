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
  final String? initialGroupId;
  const CategoryScreen({Key? key, this.initialGroupId}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<Map<String, String>> _leftCategories = [];
  final List<String> _groupIds = [];
  final CategoryGroupService _service = CategoryGroupService();
  bool _loadingLeft = true;
  String? _errorMessage;
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
          _groupIds.add(g.maNhomLoai);
          _leftCategories.add({'id': g.maNhomLoai, 'title': g.tenNhomLoai});
        }
        _loadingLeft = false;
      });

      if (_groupIds.isNotEmpty) {
        int initialIndex = 0;
        if (widget.initialGroupId != null) {
          final foundIndex = _groupIds.indexOf(widget.initialGroupId!);
          if (foundIndex != -1) {
            initialIndex = foundIndex;
          }
        }

        final firstId = _groupIds[initialIndex];
        setState(() {
          _selectedIndex = initialIndex;
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Row(
                children: [
                  // Left Sidebar
                  Container(
                    width: 100,
                    color: Colors.white,
                    child: _buildLeftContent(),
                  ),
                  // Vertical Divider
                  Container(width: 1, color: Colors.grey[200]),
                  // Right Content
                  Expanded(
                    child: Container(
                      color: const Color(0xFFF5F7FA),
                      child: _buildRightContent(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.grey, size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tìm kiếm danh mục...',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Consumer<CartProvider>(
            builder:
                (_, cart, __) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                      icon: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Color(0xFF023350),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    if (cart.items.isNotEmpty)
                      Positioned(
                        right: -4,
                        top: -4,
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
    );
  }

  Widget _buildLeftContent() {
    if (_loadingLeft) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_errorMessage != null) {
      return Center(
        child: IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF03A297)),
          onPressed: _fetchCategories,
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _leftCategories.length,
      itemBuilder: (context, index) {
        final item = _leftCategories[index];
        final selected = index == _selectedIndex;
        return InkWell(
          onTap: () => _onSelectGroup(index),
          child: Container(
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFF0FDF9) : Colors.white,
              border:
                  selected
                      ? const Border(
                        left: BorderSide(color: Color(0xFF03A297), width: 4),
                      )
                      : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.grey[50],
                    shape: BoxShape.circle,
                    boxShadow:
                        selected
                            ? [
                              BoxShadow(
                                color: const Color(0xFF03A297).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: Icon(
                    IconGenerator.getIconForMedicineType(item['title'] ?? ''),
                    color:
                        selected ? const Color(0xFF03A297) : Colors.grey[400],
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['title'] ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color:
                        selected ? const Color(0xFF03A297) : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRightContent() {
    if (_loadingTypes) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_typesError != null) {
      return Center(child: Text('Lỗi: $_typesError'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final mq = MediaQuery.of(context);
        final bottomInset = mq.padding.bottom + kBottomNavigationBarHeight + 80;

        return GridView.builder(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: bottomInset,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _types.length,
          itemBuilder: (context, i) {
            final t = _types[i];
            return _buildTypeCard(t);
          },
        );
      },
    );
  }

  Widget _buildTypeCard(CategoryType t) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (_) => MedicinesByTypeScreen(
                      maLoai: t.maLoaiThuoc,
                      tenLoai: t.tenLoaiThuoc,
                    ),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: IconGenerator.getColorForMedicineType(
                    t.tenLoaiThuoc,
                  ).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconGenerator.getIconForMedicineType(t.tenLoaiThuoc),
                  size: 24,
                  color: IconGenerator.getColorForMedicineType(t.tenLoaiThuoc),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  t.tenLoaiThuoc,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSelectGroup(int index) {
    final item = _leftCategories[index];
    final id =
        (index < _groupIds.length && _groupIds[index].isNotEmpty)
            ? _groupIds[index]
            : (item['id']);

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
      final types = await _service.getTypesByGroup(maNhomLoai);
      setState(() {
        _types = types;
        _loadingTypes = false;
      });
    } catch (e) {
      setState(() {
        _typesError = e.toString();
        _loadingTypes = false;
      });
    }
  }
}
