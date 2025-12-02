import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_nha_thuoc/providers/auth_provider.dart';
import 'package:quan_ly_nha_thuoc/theme/app_theme.dart';
import 'package:quan_ly_nha_thuoc/utils/constants.dart';
import 'package:quan_ly_nha_thuoc/utils/validators.dart';
import 'package:quan_ly_nha_thuoc/utils/snackbar_helper.dart';
import 'package:quan_ly_nha_thuoc/widgets/custom_button.dart';
import 'package:quan_ly_nha_thuoc/widgets/custom_text_field.dart';
import 'package:quan_ly_nha_thuoc/services/auth_service.dart';
import 'dart:async';

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

  // Username checking state
  Timer? _usernameCheckTimer;
  bool _isCheckingUsername = false;
  bool _isUsernameAvailable = false;
  String? _usernameError;

  // Terms agreement
  bool _agreeTerms = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameCheckTimer?.cancel();
    _usernameController.removeListener(_onUsernameChanged);
    _passwordController.removeListener(() => setState(() {}));
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Check username availability with debounce
  void _onUsernameChanged() {
    _usernameCheckTimer?.cancel();

    final username = _usernameController.text.trim();

    // Reset state
    setState(() {
      _isCheckingUsername = false;
      _isUsernameAvailable = false;
      _usernameError = null;
    });

    // Validate length first
    if (username.length < 6) {
      if (username.isNotEmpty) {
        setState(() {
          _usernameError = 'Tên đăng nhập phải có ít nhất 6 ký tự';
        });
      }
      return;
    }

    if (username.length > 50) {
      setState(() {
        _usernameError = 'Tên đăng nhập không được quá 50 ký tự';
      });
      return;
    }

    // Show checking status
    setState(() {
      _isCheckingUsername = true;
    });

    // Debounce API call
    _usernameCheckTimer = Timer(const Duration(milliseconds: 500), () async {
      await _checkUsernameAvailability(username);
    });
  }

  /// Call API to check username availability
  Future<void> _checkUsernameAvailability(String username) async {
    try {
      final authService = AuthService();
      final exists = await authService.checkUsernameExists(username);

      if (!mounted) return;

      setState(() {
        _isCheckingUsername = false;
        if (exists) {
          _isUsernameAvailable = false;
          _usernameError = 'Tên đăng nhập đã tồn tại';
        } else {
          _isUsernameAvailable = true;
          _usernameError = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      // Nếu API chưa sẵn sàng (404), tạm thời cho phép đăng ký
      // User sẽ nhận lỗi khi submit nếu username thực sự đã tồn tại
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = true; // Cho phép tiếp tục
        _usernameError = null; // Không hiển thị lỗi
      });
      print('Username check API not available: $e');
    }
  }

  /// Handle register
  Future<void> _handleRegister() async {
    // Clear previous error
    context.read<AuthProvider>().clearError();

    // Check username availability
    if (!_isUsernameAvailable) {
      SnackBarHelper.show(
        context,
        _usernameError ?? 'Vui lòng chọn tên đăng nhập khác',
        type: SnackBarType.error,
      );
      return;
    }

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check terms agreement
    if (!_agreeTerms) {
      SnackBarHelper.show(
        context,
        'Vui lòng đồng ý với điều khoản dịch vụ',
        type: SnackBarType.error,
      );
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
      // Show success dialog
      await _showSuccessDialog();
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

  /// Show success dialog after registration
  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 50,
                      color: AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'Đăng Ký Thành Công!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Message
                  const Text(
                    'Vui lòng đăng nhập và hoàn thiện thông tin cá nhân để sử dụng đầy đủ tính năng của ứng dụng.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Đến trang đăng nhập',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
                                  // Username field with availability check
                                  CustomTextField(
                                    controller: _usernameController,
                                    labelText: 'Tên đăng nhập',
                                    hintText: 'Nhập tên đăng nhập (6-50 ký tự)',
                                    prefixIcon: Icons.person_outline,
                                    validator: (value) {
                                      // Only validate basic rules, not availability
                                      return Validators.validateUsername(value);
                                    },
                                    textInputAction: TextInputAction.next,
                                    suffixIcon:
                                        _isCheckingUsername
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: Padding(
                                                padding: EdgeInsets.all(12),
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            )
                                            : _isUsernameAvailable
                                            ? const Icon(
                                              Icons.check_circle,
                                              color: AppTheme.successColor,
                                            )
                                            : _usernameError != null &&
                                                _usernameController.text
                                                        .trim()
                                                        .length >=
                                                    6
                                            ? const Icon(
                                              Icons.error,
                                              color: AppTheme.errorColor,
                                            )
                                            : null,
                                  ),
                                  if (_usernameError != null &&
                                      _usernameController.text.trim().length >=
                                          6)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 4,
                                        left: 12,
                                      ),
                                      child: Text(
                                        _usernameError!,
                                        style: const TextStyle(
                                          color: AppTheme.errorColor,
                                          fontSize: 12,
                                        ),
                                      ),
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
                                  const SizedBox(height: 16),

                                  // Terms agreement
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _agreeTerms = !_agreeTerms;
                                      });
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Checkbox(
                                          value: _agreeTerms,
                                          onChanged: (value) {
                                            setState(() {
                                              _agreeTerms = value ?? false;
                                            });
                                          },
                                          activeColor: AppTheme.primaryColor,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 12,
                                            ),
                                            child: RichText(
                                              text: const TextSpan(
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color:
                                                      AppTheme
                                                          .textSecondaryColor,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: 'Tôi đồng ý với ',
                                                  ),
                                                  TextSpan(
                                                    text: 'Điều khoản dịch vụ',
                                                    style: TextStyle(
                                                      color:
                                                          AppTheme.primaryColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  TextSpan(text: ' và '),
                                                  TextSpan(
                                                    text: 'Chính sách bảo mật',
                                                    style: TextStyle(
                                                      color:
                                                          AppTheme.primaryColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
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
