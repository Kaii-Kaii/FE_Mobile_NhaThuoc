import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/cart_provider.dart';
import '../../screens/home/home_page_screen.dart';
import '../../screens/medicines/medicine_list_screen.dart';
import '../../theme/app_theme.dart';
import '../../utils/storage_helper.dart';

/// Main entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  await StorageHelper.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

/// Root App Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        // Customer Provider
        ChangeNotifierProvider(create: (_) => CustomerProvider()..init()),
        // Cart Provider
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Nhà Thuốc Medion',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme.copyWith(
          colorScheme: AppTheme.lightTheme.colorScheme.copyWith(
            primary: const Color(0xFF023350),
            secondary: const Color(0xFF03A297),
          ),
        ),
        // Directly go to HomePageScreen
        home: const HomePageScreen(),
        // Named routes
        routes: {'/medicines': (context) => const MedicineListScreen()},
      ),
    );
  }
}
