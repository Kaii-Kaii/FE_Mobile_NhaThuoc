import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_nha_thuoc/providers/auth_provider.dart';
import 'package:quan_ly_nha_thuoc/providers/cart_provider.dart';
import 'package:quan_ly_nha_thuoc/providers/customer_provider.dart';
import 'package:quan_ly_nha_thuoc/providers/medicine_provider.dart';
import 'package:quan_ly_nha_thuoc/screens/auth/customer_info_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/auth/login_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/auth/register_screen.dart';
import 'package:quan_ly_nha_thuoc/services/api_service.dart';

import 'package:quan_ly_nha_thuoc/screens/main_screen.dart';
import 'package:quan_ly_nha_thuoc/theme/app_theme.dart';
import 'package:quan_ly_nha_thuoc/utils/constants.dart';
import 'package:quan_ly_nha_thuoc/utils/storage_helper.dart';

/// Global navigator key để điều hướng từ bất kỳ đâu
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Main entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with manual configuration
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyD0Ovif0HZh5MoxkMfdlTCHvoLjFoLY6tk',
      appId: '1:272239333832:android:1770eb39680ac6c5ca30fd',
      messagingSenderId: '272239333832',
      projectId: 'nhathuoc-f9fce',
      storageBucket: 'nhathuoc-f9fce.firebasestorage.app',
    ),
  );

  // Initialize SharedPreferences
  await StorageHelper.init();

  // Thiết lập callback xử lý khi token JWT hết hạn
  ApiService.onTokenExpired = () {
    // Điều hướng về màn hình đăng nhập khi token hết hạn
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppConstants.loginRoute,
      (route) => false,
    );
  };

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

        // Sử dụng navigatorKey để có thể điều hướng từ bất kỳ đâu
        navigatorKey: navigatorKey,

        // Start directly at MainScreen for development/testing
        home: MainScreen(key: MainScreen.globalKey),

        // Named routes
        routes: {
          AppConstants.loginRoute: (context) => const LoginScreen(),
          AppConstants.registerRoute: (context) => const RegisterScreen(),
          AppConstants.customerInfoRoute:
              (context) => const CustomerInfoScreen(),
          AppConstants.homeRoute:
              (context) => MainScreen(key: MainScreen.globalKey),
          AppConstants.accountRoute:
              (context) =>
                  MainScreen(key: MainScreen.globalKey, initialIndex: 3),
        },
      ),
    );
  }
}

    // Note: InitialScreen redirect logic is intentionally removed here so the
    // app starts directly on HomePageScreen during development. If you want to
    // restore the original auth-based redirect, re-add the InitialScreen class
    // and set home: InitialScreen().
