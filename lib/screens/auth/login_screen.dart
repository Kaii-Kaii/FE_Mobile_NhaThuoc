import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_nha_thuoc/providers/auth_provider.dart';
import 'package:quan_ly_nha_thuoc/providers/customer_provider.dart';
import 'package:quan_ly_nha_thuoc/theme/app_theme.dart';
import 'package:quan_ly_nha_thuoc/utils/constants.dart';
import 'package:quan_ly_nha_thuoc/utils/validators.dart';
import 'package:quan_ly_nha_thuoc/widgets/custom_button.dart';
import 'package:quan_ly_nha_thuoc/widgets/custom_text_field.dart';

/// Login Screen
/// Màn hình đăng nhập với đầy đủ chức năng
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  String? _redirectRoute;
  bool _popOnSuccess = false;
  bool _didLoadRouteArgs = false;

  @override
  void initState() {
    super.initState();
    // Load remember me preference
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        _rememberMe = authProvider.rememberMe;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadRouteArgs) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final redirect = args['redirectRoute'];
      if (redirect is String && redirect.isNotEmpty) {
        _redirectRoute = redirect;
      }
    } else if (args is String && args.isNotEmpty) {
      _redirectRoute = args;
    }

    if (args is Map<String, dynamic>) {
      _popOnSuccess = args['popOnSuccess'] ?? false;
    }

    _didLoadRouteArgs = true;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login
  Future<void> _handleLogin() async {
    // Clear previous error
    context.read<AuthProvider>().clearError();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );

    // Set remember me
    authProvider.setRememberMe(_rememberMe);

    // Call login API
    final success = await authProvider.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Clear any cached customer data to avoid stale info between accounts
      await customerProvider.clearCustomer();

      bool hasCustomerInfo = false;
      final loggedInUser = authProvider.user;

      if (loggedInUser?.maKhachHang != null) {
        final fetched = await customerProvider.getCustomer(
          loggedInUser!.maKhachHang!,
        );

        if (!fetched && customerProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(customerProvider.errorMessage!),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        hasCustomerInfo = fetched && customerProvider.customer != null;
      }

      final redirectRoute =
          (_redirectRoute == AppConstants.customerInfoRoute ||
                  _redirectRoute == null)
              ? AppConstants.homeRoute
              : _redirectRoute!;

      if (hasCustomerInfo) {
        if (_popOnSuccess) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacementNamed(redirectRoute);
        }
      } else {
        Navigator.of(context).pushReplacementNamed(
          AppConstants.customerInfoRoute,
          arguments: {
            "redirectRoute": redirectRoute,
            "popOnSuccess": _popOnSuccess,
          },
        );
      }
    } else {
      // Show error message
      if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        size: 50,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Nhà Thuốc Medion',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đăng nhập để tiếp tục',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Login Card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Username field
                            CustomTextField(
                              controller: _usernameController,
                              labelText: 'Tên đăng nhập',
                              hintText: 'Nhập tên đăng nhập',
                              prefixIcon: Icons.person_outline,
                              validator: Validators.validateUsername,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),

                            // Password field
                            PasswordTextField(
                              controller: _passwordController,
                              labelText: 'Mật khẩu',
                              hintText: 'Nhập mật khẩu',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleLogin(),
                            ),
                            const SizedBox(height: 16),

                            // Remember me & Forgot password
                            Row(
                              children: [
                                // Remember me checkbox
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    activeColor: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Ghi nhớ đăng nhập',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const Spacer(),

                                // Forgot password
                                TextButton(
                                  onPressed: () {
                                    // TODO: Implement forgot password
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Chức năng đang phát triển',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Quên mật khẩu?',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Login button
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return CustomButton(
                                  text: 'Đăng nhập',
                                  onPressed: _handleLogin,
                                  isLoading: authProvider.isLoading,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Social login buttons
                    const Text(
                      'Hoặc đăng nhập với',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google button
                        _SocialButton(
                          icon: FontAwesomeIcons.google,
                          color: const Color(0xFFDB4437),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chức năng đang phát triển'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),

                        // Facebook button
                        _SocialButton(
                          icon: FontAwesomeIcons.facebook,
                          color: const Color(0xFF4267B2),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chức năng đang phát triển'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Chưa có tài khoản? ',
                          style: TextStyle(fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppConstants.registerRoute);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: const Text(
                            'Đăng ký ngay',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Social Login Button Widget
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Center(child: FaIcon(icon, color: color, size: 24)),
        ),
      ),
    );
  }
}
