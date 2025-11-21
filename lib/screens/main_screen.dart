import 'package:flutter/material.dart';
import 'package:quan_ly_nha_thuoc/screens/home/account_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/home/category_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/home/home_page_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/order_history/order_history_screen.dart';
import 'package:quan_ly_nha_thuoc/widgets/app_bottom_nav.dart';
import 'package:quan_ly_nha_thuoc/widgets/center_floating_button.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static MainScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainScreenState>();
  }

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomePageScreen(),
    const CategoryScreen(),
    const OrderHistoryScreen(),
    const AccountScreen(),
  ];

  void setIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        activeIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButton: const CenterFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
