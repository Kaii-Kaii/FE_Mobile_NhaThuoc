import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_nha_thuoc/providers/auth_provider.dart';
import 'package:quan_ly_nha_thuoc/providers/customer_provider.dart';
import 'package:quan_ly_nha_thuoc/screens/auth/customer_info_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/auth/login_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/auth/register_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/home/home_screen.dart';
import 'package:quan_ly_nha_thuoc/screens/splash_screen.dart';
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
      ],
      child: MaterialApp(
        title: 'Nhà Thuốc Medion',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        // Initial route
        home: const InitialScreen(),

        // Named routes
        routes: {
          AppConstants.loginRoute: (context) => const LoginScreen(),
          AppConstants.registerRoute: (context) => const RegisterScreen(),
          AppConstants.customerInfoRoute:
              (context) => const CustomerInfoScreen(),
          AppConstants.homeRoute: (context) => const HomeScreen(),
        },
      ),
    );
  }
}

/// Initial Screen
/// Screen khởi động với auto-redirect logic
class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  /// Check authentication và navigate
  Future<void> _checkAuthAndNavigate() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );

    // Auto-redirect logic
    if (authProvider.isLoggedIn) {
      // Đã login
      if (customerProvider.hasCustomerInfo) {
        // Có customer info → Chuyển đến home
        Navigator.of(context).pushReplacementNamed(AppConstants.homeRoute);
      } else {
        // Chưa có customer info → Chuyển đến customer info screen
        Navigator.of(
          context,
        ).pushReplacementNamed(AppConstants.customerInfoRoute);
      }
    } else {
      // Chưa login → Chuyển đến login screen
      Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
