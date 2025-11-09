import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/medicine_model.dart';
import './cart_screen.dart';
import './medicine_detail_screen.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({Key? key}) : super(key: key);

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  final List<String> _categories = ['Tất cả', 'Thuốc kê đơn', 'Thuốc không kê đơn', 'Thực phẩm chức năng', 'Dụng cụ y tế'];
  
  // Dummy data cho giao diện
  final List<Medicine> _dummyMedicines = [
    Medicine(
      id: 1,
      name: 'Paracetamol',
      description: 'Thuốc giảm đau, hạ sốt',
      price: 15000,
      image: 'https://cdn.nhathuoclongchau.com.vn/unsafe/373x0/filters:quality(90)/https://cms-prod.s3-sgn09.fptcloud.com/00502L_paracetamol_500mg_hapharco_hop_10_vi_x_10_vien_7302_61c1_large_92f99a9343.JPG',
      category: 'Thuốc không kê đơn',
      stockQuantity: 100,
      manufacturer: 'Dược Hậu Giang',
      dosageForm: 'Viên nén',
      dosageInstructions: 'Uống 1-2 viên mỗi 4-6 giờ khi cần',
      requiresPrescription: false,
    ),
    Medicine(
      id: 2,
      name: 'Amoxicillin',
      description: 'Kháng sinh điều trị nhiễm khuẩn',
      price: 25000,
      image: 'https://cdn.nhathuoclongchau.com.vn/unsafe/373x0/filters:quality(90)/https://cms-prod.s3-sgn09.fptcloud.com/00029587_amoxicilin_500mg_glomed_3_vi_x_10_vien_2299_6232_large_1bc99e954a.jpg',
      category: 'Thuốc kê đơn',
      stockQuantity: 50,
      manufacturer: 'Sanofi',
      dosageForm: 'Viên nang',
      dosageInstructions: 'Uống 1 viên, 3 lần/ngày sau ăn',
      requiresPrescription: true,
    ),
    Medicine(
      id: 3,
      name: 'Vitamin C',
      description: 'Bổ sung vitamin C',
      price: 35000,
      image: 'https://cdn.nhathuoclongchau.com.vn/unsafe/373x0/filters:quality(90)/https://cms-prod.s3-sgn09.fptcloud.com/DSC_00743_81b06b33d3.jpg',
      category: 'Thực phẩm chức năng',
      stockQuantity: 200,
      manufacturer: 'Pharma',
      dosageForm: 'Viên nén sủi',
      dosageInstructions: 'Uống 1 viên/ngày',
      requiresPrescription: false,
    ),
    Medicine(
      id: 4,
      name: 'Máy đo huyết áp',
      description: 'Thiết bị đo huyết áp điện tử',
      price: 850000,
      image: 'https://cdn.nhathuoclongchau.com.vn/unsafe/373x0/filters:quality(90)/https://cms-prod.s3-sgn09.fptcloud.com/may_do_huyet_ap_bap_tay_omron_hem_7120_7ef245ba3a.png',
      category: 'Dụng cụ y tế',
      stockQuantity: 10,
      manufacturer: 'Omron',
      dosageForm: 'Thiết bị',
      dosageInstructions: 'Sử dụng theo hướng dẫn',
      requiresPrescription: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Danh sách thuốc'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategorySelector(),
          Expanded(
            child: _buildMedicineGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm thuốc...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (value) {
          // Search functionality will be implemented later
        },
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.secondaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicineGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _dummyMedicines.length,
      itemBuilder: (context, index) {
        final medicine = _dummyMedicines[index];
        return _buildMedicineCard(medicine);
      },
    );
  }

  Widget _buildMedicineCard(Medicine medicine) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicineDetailScreen(maThuoc: medicine.id.toString()),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh thuốc
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Image.network(
                  medicine.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      alignment: Alignment.center,
                    );
                  },
                ),
              ),
            ),
            // Thông tin thuốc
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tên thuốc
                    Text(
                      medicine.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Mô tả ngắn
                    Text(
                      medicine.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Giá và nút thêm vào giỏ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${medicine.price.toInt().toString()} đ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã thêm ${medicine.name} vào giỏ hàng'),
                                backgroundColor: AppTheme.secondaryColor,
                                action: SnackBarAction(
                                  label: 'XEM GIỎ',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const CartScreen()),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}