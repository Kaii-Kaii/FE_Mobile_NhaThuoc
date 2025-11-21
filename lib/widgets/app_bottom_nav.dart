import 'package:flutter/material.dart';

typedef NavItemSelected = void Function(int index);

class AppBottomNavBar extends StatelessWidget implements PreferredSizeWidget {
  final int activeIndex;
  final NavItemSelected? onItemSelected;

  const AppBottomNavBar({Key? key, this.activeIndex = 0, this.onItemSelected}) : super(key: key);

  static const double _height = 64;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home, 'label': 'Trang chủ'},
      {'icon': Icons.menu_book, 'label': 'Danh mục'},
      {'icon': Icons.history, 'label': 'Lịch sử đơn hàng'},
      {'icon': Icons.person, 'label': 'Tài khoản'},
    ];

    Widget buildItem(int i, IconData icon, String label) {
      final active = i == activeIndex;
      return InkWell(
        onTap: () {
          if (onItemSelected != null) onItemSelected!(i);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? const Color(0xFF03A297) : Colors.grey),
            Text(label, style: TextStyle(color: active ? const Color(0xFF03A297) : Colors.grey, fontSize: 11)),
          ],
        ),
      );
    }

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: _height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildItem(0, items[0]['icon'] as IconData, items[0]['label'] as String),
            buildItem(1, items[1]['icon'] as IconData, items[1]['label'] as String),
            const SizedBox(width: 56),
            buildItem(2, items[2]['icon'] as IconData, items[2]['label'] as String),
            buildItem(3, items[3]['icon'] as IconData, items[3]['label'] as String),
          ],
        ),
      ),
    );
  }
}
