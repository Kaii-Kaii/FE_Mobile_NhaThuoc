import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_nha_thuoc/providers/auth_provider.dart';
import 'package:quan_ly_nha_thuoc/providers/cart_provider.dart';
import 'package:quan_ly_nha_thuoc/providers/customer_provider.dart';
import 'package:quan_ly_nha_thuoc/providers/medicine_provider.dart';
import 'package:quan_ly_nha_thuoc/screens/auth/customer_info_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/auth/login_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/auth/register_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/home/account_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/home/home_page_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/main_screen.dart';
import 'package:quan_ly_nha_thuoc/theme/app_theme.dart';
import 'package:quan_ly_nha_thuoc/utils/constants.dart';
import 'package:quan_ly_nha_thuoc/utils/storage_helper.dart';

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
        // Medicine Provider
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
      ],
      child: MaterialApp(
        title: 'Nhà Thuốc Medion',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        // Start directly at MainScreen for development/testing
        home: const MainScreen(),

        // Named routes
        routes: {
          AppConstants.loginRoute: (context) => const LoginScreen(),
          AppConstants.registerRoute: (context) => const RegisterScreen(),
          AppConstants.customerInfoRoute:
              (context) => const CustomerInfoScreen(),
          AppConstants.homeRoute: (context) => const MainScreen(),
          AppConstants.accountRoute: (context) => const AccountScreen(),
        },
      ),
    );
  }
}

    // Note: InitialScreen redirect logic is intentionally removed here so the
    // app starts directly on HomePageScreen during development. If you want to
    // restore the original auth-based redirect, re-add the InitialScreen class
    // and set home: InitialScreen().
