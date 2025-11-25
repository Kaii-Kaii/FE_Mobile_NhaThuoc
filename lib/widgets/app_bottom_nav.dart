import 'package:flutter/material.dart';
import 'package:quan_ly_nha_thuoc/theme/app_theme.dart';

typedef NavItemSelected = void Function(int index);

class AppBottomNavBar extends StatelessWidget implements PreferredSizeWidget {
  final int activeIndex;
  final NavItemSelected? onItemSelected;

  const AppBottomNavBar({super.key, this.activeIndex = 0, this.onItemSelected});

  static const double _height = 80;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home, 'label': 'Trang chủ'},
      {'icon': Icons.shopping_cart, 'label': 'Giỏ hàng'},
      {'icon': Icons.history, 'label': 'Lịch sử đơn'},
      {'icon': Icons.person, 'label': 'Tài khoản'},
    ];

    Widget buildItem(int i, IconData icon, String label) {
      final active = i == activeIndex;
      return InkWell(
        onTap: () {
          if (onItemSelected != null) onItemSelected!(i);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? AppTheme.secondaryColor : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? AppTheme.secondaryColor : Colors.grey,
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: _height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final itemWidth = (width - 56) / 4; // 56 is FAB width gap

            double getIndicatorLeft(int index) {
              if (index < 2) {
                return index * itemWidth;
              } else {
                return index * itemWidth + 56;
              }
            }

            return Stack(
              children: [
                // Sliding Indicator (Pill Shape)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left:
                      getIndicatorLeft(activeIndex) +
                      (itemWidth - 64) / 2, // Center horizontally
                  top: 16, // Align with the icon
                  width: 64,
                  height: 32,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                // Items
                Row(
                  children: [
                    Expanded(
                      child: buildItem(
                        0,
                        items[0]['icon'] as IconData,
                        items[0]['label'] as String,
                      ),
                    ),
                    Expanded(
                      child: buildItem(
                        1,
                        items[1]['icon'] as IconData,
                        items[1]['label'] as String,
                      ),
                    ),
                    const SizedBox(width: 56),
                    Expanded(
                      child: buildItem(
                        2,
                        items[2]['icon'] as IconData,
                        items[2]['label'] as String,
                      ),
                    ),
                    Expanded(
                      child: buildItem(
                        3,
                        items[3]['icon'] as IconData,
                        items[3]['label'] as String,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
