import 'package:flutter/material.dart';
import '../../models/medicine_model.dart';
import 'medicine_detail_screen.dart';

class FamilyMedicineScreen extends StatefulWidget {
  const FamilyMedicineScreen({Key? key}) : super(key: key);

  @override
  State<FamilyMedicineScreen> createState() => _FamilyMedicineScreenState();
}

class _FamilyMedicineScreenState extends State<FamilyMedicineScreen> {
  String _selectedCategory = 'Giảm đau, hạ sốt';
  final List<String> _categories = [
    'Giảm đau, hạ sốt',
    'Mắt, tai - mũi - họng',
    'Tiêu hóa',
    'Hô hấp',
    'Da liễu',
    'Vitamin'
  ];

  // Danh sách thuốc mẫu
  final List<Medicine> _dummyMedicines = [
    Medicine(
      id: 1,
      name: 'Viên sủi Panadol 500mg giảm đau hạ sốt',
      description: 'Thuốc giảm đau, hạ sốt',
      price: 85000,
      image: 'https://cdn.nhathuoclongchau.com.vn/unsafe/373x0/filters:quality(90)/https://cms-prod.s3-sgn09.fptcloud.com/00502L_panadol_500mg_hapharco_hop_10_vi_x_10_vien_7302_61c1_large_92f99a9343.JPG',
      category: 'Giảm đau, hạ sốt',
      stockQuantity: 100,
      manufacturer: 'GSK',
      dosageForm: 'Hộp',
      dosageInstructions: 'Uống 1 viên khi đau đầu, hạ sốt',
      requiresPrescription: false,
    ),
    Medicine(
      id: 2,
      name: 'Thuốc cốm Agimol 325 giảm đau hạ sốt',
      description: 'Thuốc giảm đau, hạ sốt',
      price: 1600,
      image: 'https://cdn.nhathuoclongchau.com.vn/unsafe/373x0/filters:quality(90)/https://cms-prod.s3-sgn09.fptcloud.com/00500605_com_agimol_325mg_agrapharm_30_goi_x_1_5g_1380_6226_large_1b62b3c883.jpg',
      category: 'Giảm đau, hạ sốt',
      stockQuantity: 200,
      manufacturer: 'Agrapharm',
      dosageForm: 'Gói',
      dosageInstructions: 'Uống 1 gói mỗi 4-6 giờ khi cần',
      requiresPrescription: false,
    ),
    Medicine(
      id: 3,
      name: 'Thuốc giảm đau hạ sốt ACEp 325mg',
      description: 'Thuốc giảm đau, hạ sốt',
      price: 1300,
      image: 'https://cdn.nhathuoclongchau.com.vn/unsafe/373x0/filters:quality(90)/https://cms-prod.s3-sgn09.fptcloud.com/00500617_vien_sui_aceclo_agimexpharm_30_ong_x_1_tuy_1382_615f_large_2900c5183a.jpg',
      category: 'Giảm đau, hạ sốt',
      stockQuantity: 150,
      manufacturer: 'ACEP',
      dosageForm: 'Gói',
      dosageInstructions: 'Uống 1 gói sau khi ăn',
      requiresPrescription: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF03A297),
        title: const Text(
          'Tủ thuốc gia đình',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          _buildCategorySelector(),
          Expanded(
            child: _buildMedicineList(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildCenterButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF03A297),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              'https://img.freepik.com/free-photo/happy-family-with-grandfather-front-view_23-2148948596.jpg?w=900&t=st=1698163388~exp=1698163988~hmac=ac98d413c4a71c2aff210942e88ebb5856c7ca9a1a9c5c3fae0e97fb8e6d4c0a',
              width: 120,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tủ thuốc',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'gia đình',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 16),
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
                color: isSelected ? const Color(0xFF03A297) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF03A297) : Colors.grey.shade300,
                ),
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

  Widget _buildMedicineList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh sản phẩm
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                medicine.image,
                width: 100,
                height: 140,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 140,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            
            // Thông tin sản phẩm
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '6 vỉ x 4 viên',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Thông tin đóng gói
                    Row(
                      children: [
                        _buildPackageType('Hộp', isSelected: true),
                        const SizedBox(width: 8),
                        _buildPackageType('Vỉ'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Giá và nút thêm vào giỏ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${medicine.price.toInt()}đ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF03A297),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Thêm vào giỏ',
                            style: TextStyle(fontSize: 12),
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

  Widget _buildPackageType(String type, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8F7F6) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF03A297) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? const Color(0xFF03A297) : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home, 'Trang chủ'),
            _buildNavItem(Icons.menu, 'Danh mục'),
            const SizedBox(width: 60), // Space for FAB
            _buildNavItem(Icons.notifications, 'Thông báo'),
            _buildNavItem(Icons.person, 'Tài khoản'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return InkWell(
      onTap: () {
        if (label == 'Trang chủ') {
          Navigator.of(context).pop();
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.grey,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: FloatingActionButton(
        backgroundColor: const Color(0xFF03A297),
        child: const Icon(Icons.chat_bubble),
        onPressed: () {},
      ),
    );
  }
}