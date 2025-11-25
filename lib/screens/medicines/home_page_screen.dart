import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/medicine_navigation.dart';
import 'medicine_list_screen.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildWelcomeCard(),
            _buildQuickActions(),
            _buildFeatureSlider(),
            const SizedBox(height: 70), // Space for bottom navigation
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildCenterButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 45, left: 16, right: 16, bottom: 10),
      decoration: const BoxDecoration(color: Color(0xFF023350)),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20,
            child: Icon(Icons.local_pharmacy, color: Color(0xFF023350)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'NHÀ THUỐC',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                'AN KHANG',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.cancel_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(color: Color(0xFF023350)),
      child: Column(
        children: [
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.search, color: Colors.grey),
                ),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF03A297),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 16),
              const SizedBox(width: 5),
              const Text(
                'Giao hàng tại: ',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              const Text(
                'Hồ Chí Minh',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF03A297),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shopping_cart, color: Colors.white, size: 16),
                    SizedBox(width: 5),
                    Text(
                      '0',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chào mừng đến với Nhà thuốc An Khang',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildServiceButton(
                icon: Icons.chat,
                color: const Color(0xFF03A297),
                label: 'Chat với Dược sĩ',
              ),
              const SizedBox(width: 16),
              _buildServiceButton(
                icon: Icons.monetization_on,
                color: const Color(0xFF03A297),
                label: 'Tra giá thuốc',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButton({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 20,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.medication,
        'color': const Color(0xFF03A297),
        'label': 'Tủ thuốc\ngia đình',
      },
      {
        'icon': Icons.verified,
        'color': const Color(0xFF03A297),
        'label': 'Tra cứu\nchính hãng',
      },
      {
        'icon': Icons.receipt_long,
        'color': const Color(0xFF03A297),
        'label': 'Đơn hàng\ncủa tôi',
      },
      {
        'icon': Icons.calendar_today,
        'color': const Color(0xFF03A297),
        'label': 'Đặt lịch\nkhám bệnh',
      },
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                actions
                    .map(
                      (action) => _buildQuickActionItem(
                        icon: action['icon'],
                        color: action['color'],
                        label: action['label'],
                      ),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBadge(Icons.medical_information, 'Cam kết', null),
            _buildBadge(Icons.verified, '100% hàng chính hãng', null),
            _buildBadge(null, 'Min', const Color(0xFFFF6600)),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(IconData? icon, String text, Color? textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, size: 16, color: textColor ?? const Color(0xFF03A297)),
          if (icon != null) const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSlider() {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 18 / 9,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
              image: const DecorationImage(
                image: NetworkImage(
                  'https://i.imgur.com/15kTV6E.jpg', // Banner giống ảnh tham khảo với tone màu xanh
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF03A297),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            ...List.generate(
              2,
              (index) => Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
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
            _buildNavItem(0, Icons.home, 'Trang chủ'),
            _buildNavItem(1, Icons.menu, 'Danh mục'),
            const SizedBox(width: 60), // Space for FAB
            _buildNavItem(2, Icons.notifications, 'Thông báo'),
            _buildNavItem(3, Icons.person, 'Tài khoản'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF03A297) : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF03A297) : Colors.grey,
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
        child: const Icon(Icons.medical_services),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MedicineListScreen()),
          );
        },
      ),
    );
  }
}
