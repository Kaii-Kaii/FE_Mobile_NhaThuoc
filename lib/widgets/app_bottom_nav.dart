import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_nha_thuoc/providers/cart_provider.dart';
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

      Widget iconWidget = Icon(
        icon,
        color: active ? AppTheme.secondaryColor : Colors.grey,
      );

      if (i == 1) {
        // Cart index
        iconWidget = Consumer<CartProvider>(
          builder: (context, cart, child) {
            final count = cart.items.length;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: active ? AppTheme.secondaryColor : Colors.grey,
                ),
                if (count > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      }

      return InkWell(
        onTap: () {
          if (onItemSelected != null) onItemSelected!(i);
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color:
                active
                    ? AppTheme.secondaryColor.withOpacity(0.15)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(height: 2),
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
        ),
      );
    }

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: _height,
        child: Row(
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
      ),
    );
  }
}
