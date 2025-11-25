import 'package:flutter/material.dart';
import 'package:quan_ly_nha_thuoc/screens/home/account_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/home/category_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/home/home_page_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/medicines/cart_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/order_history/order_history_screen.dart';
import 'package:quan_ly_nha_thuoc/widgets/app_bottom_nav.dart';
import 'package:quan_ly_nha_thuoc/widgets/center_floating_button.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  static final GlobalKey<MainScreenState> globalKey =
      GlobalKey<MainScreenState>();

  const MainScreen({super.key, this.initialIndex = 0});

  static MainScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainScreenState>();
  }

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  PageController? _pageController;
  final GlobalKey<OrderHistoryScreenState> _orderHistoryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  PageController get pageController {
    _pageController ??= PageController(initialPage: _selectedIndex);
    return _pageController!;
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void setIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    if (index == 2) {
      _orderHistoryKey.currentState?.refresh();
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 2) {
      _orderHistoryKey.currentState?.refresh();
    }
  }

  void navigateToCategory(String? groupId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryScreen(initialGroupId: groupId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomePageScreen(),
      const CartScreen(),
      OrderHistoryScreen(key: _orderHistoryKey),
      const AccountScreen(),
    ];

    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        activeIndex: _selectedIndex,
        onItemSelected: setIndex,
      ),
      floatingActionButton: const CenterFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
