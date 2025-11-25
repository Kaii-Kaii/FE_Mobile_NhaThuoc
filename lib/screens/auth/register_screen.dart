import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_nha_thuoc/providers/auth_provider.dart';
import 'package:quan_ly_nha_thuoc/theme/app_theme.dart';
import 'package:quan_ly_nha_thuoc/utils/constants.dart';
import 'package:quan_ly_nha_thuoc/utils/validators.dart';
import 'package:quan_ly_nha_thuoc/utils/snackbar_helper.dart';
import 'package:quan_ly_nha_thuoc/widgets/custom_button.dart';
import 'package:quan_ly_nha_thuoc/widgets/custom_text_field.dart';

/// Register Screen
/// Màn hình đăng ký với validation phức tạp
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handle register
  Future<void> _handleRegister() async {
    // Clear previous error
    context.read<AuthProvider>().clearError();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Call register API
    final success = await authProvider.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Show success message
      // Show success message
      SnackBarHelper.show(
        context,
        AppConstants.registerSuccess,
        type: SnackBarType.success,
      );

      // Navigate to login screen
      Navigator.of(context).pop();
    } else {
      // Show error message
      if (authProvider.errorMessage != null) {
        SnackBarHelper.show(
          context,
          authProvider.errorMessage!,
          type: SnackBarType.error,
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
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Đăng ký',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
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
                            width: 80,
                            height: 80,
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
                              Icons.person_add,
                              size: 40,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Title
                          const Text(
                            'Tạo tài khoản mới',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vui lòng điền thông tin để đăng ký',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Register Card
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
                                    hintText: 'Nhập tên đăng nhập (6-50 ký tự)',
                                    prefixIcon: Icons.person_outline,
                                    validator: Validators.validateUsername,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),

                                  // Email field
                                  CustomTextField(
                                    controller: _emailController,
                                    labelText: 'Email',
                                    hintText: 'Nhập email',
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: Validators.validateEmail,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),

                                  // Password field
                                  PasswordTextField(
                                    controller: _passwordController,
                                    labelText: 'Mật khẩu',
                                    hintText:
                                        'Nhập mật khẩu (tối thiểu 8 ký tự)',
                                    validator: Validators.validatePassword,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),

                                  // Confirm password field
                                  PasswordTextField(
                                    controller: _confirmPasswordController,
                                    labelText: 'Xác nhận mật khẩu',
                                    hintText: 'Nhập lại mật khẩu',
                                    validator:
                                        (value) =>
                                            Validators.validateConfirmPassword(
                                              value,
                                              _passwordController.text,
                                            ),
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _handleRegister(),
                                  ),
                                  const SizedBox(height: 8),

                                  // Password requirements
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.backgroundColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mật khẩu phải có:',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        _PasswordRequirement(
                                          text: 'Ít nhất 8 ký tự',
                                          isMet:
                                              _passwordController.text.length >=
                                              8,
                                        ),
                                        _PasswordRequirement(
                                          text: 'Có chữ hoa (A-Z)',
                                          isMet: _passwordController.text
                                              .contains(RegExp(r'[A-Z]')),
                                        ),
                                        _PasswordRequirement(
                                          text: 'Có chữ thường (a-z)',
                                          isMet: _passwordController.text
                                              .contains(RegExp(r'[a-z]')),
                                        ),
                                        _PasswordRequirement(
                                          text: 'Có số (0-9)',
                                          isMet: _passwordController.text
                                              .contains(RegExp(r'\d')),
                                        ),
                                        _PasswordRequirement(
                                          text: 'Có ký tự đặc biệt (@\$!%*?&)',
                                          isMet: _passwordController.text
                                              .contains(RegExp(r'[@$!%*?&]')),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Register button
                                  Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      return CustomButton(
                                        text: 'Đăng ký',
                                        onPressed: _handleRegister,
                                        isLoading: authProvider.isLoading,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Đã có tài khoản? ',
                                style: TextStyle(fontSize: 14),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                                child: const Text(
                                  'Đăng nhập ngay',
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
            ],
          ),
        ),
      ),
    );
  }
}

/// Password Requirement Widget
class _PasswordRequirement extends StatelessWidget {
  final String text;
  final bool isMet;

  const _PasswordRequirement({required this.text, required this.isMet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? AppTheme.successColor : AppTheme.textLightColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color:
                  isMet ? AppTheme.successColor : AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
