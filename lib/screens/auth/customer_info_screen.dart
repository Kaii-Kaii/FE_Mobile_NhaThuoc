import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_nha_thuoc/providers/auth_provider.dart';
import 'package:quan_ly_nha_thuoc/providers/customer_provider.dart';
import 'package:quan_ly_nha_thuoc/theme/app_theme.dart';
import 'package:quan_ly_nha_thuoc/utils/constants.dart';
import 'package:quan_ly_nha_thuoc/utils/validators.dart';
import 'package:quan_ly_nha_thuoc/widgets/custom_button.dart';
import 'package:quan_ly_nha_thuoc/widgets/custom_text_field.dart';

/// Customer Info Screen
/// Màn hình nhập thông tin khách hàng với progress indicator
class CustomerInfoScreen extends StatefulWidget {
  const CustomerInfoScreen({super.key});

  @override
  State<CustomerInfoScreen> createState() => _CustomerInfoScreenState();
}

class _CustomerInfoScreenState extends State<CustomerInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedGender = 'Nam';
  String? _redirectRoute;
  bool _popOnSuccess = false;
  bool _didLoadArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadArgs) return;

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

    _didLoadArgs = true;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Select date of birth
  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 25, now.month, now.day);
    final firstDate = DateTime(now.year - AppConstants.maxAge);
    final lastDate = DateTime(now.year - AppConstants.minAge);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Handle submit
  Future<void> _handleSubmit() async {
    // Clear previous error
    context.read<CustomerProvider>().clearError();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate date
    final dateError = Validators.validateDateOfBirth(_selectedDate);
    if (dateError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dateError),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );

    // Call API
    final success = await customerProvider.createCustomer(
      hoTen: _fullNameController.text.trim(),
      ngaySinh: _selectedDate!,
      dienThoai: _phoneController.text.trim(),
      gioiTinh: _selectedGender,
      diaChi: _addressController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // Show success modal
      await _showSuccessDialog();
    } else {
      // Show error message
      if (customerProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(customerProvider.errorMessage!),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Show success dialog
  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const SizedBox(height: 16),
                const Text(
                  'Hoàn tất!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppConstants.customerInfoSuccess,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Tiếp tục',
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (_popOnSuccess) {
                      Navigator.of(context).pop();
                      return;
                    }
                    final targetRoute =
                        (_redirectRoute == null ||
                                _redirectRoute ==
                                    AppConstants.customerInfoRoute)
                            ? AppConstants.homeRoute
                            : _redirectRoute!;
                    Navigator.of(context).pushReplacementNamed(targetRoute);
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = authProvider.user?.tenDangNhap ?? 'User';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Welcome message
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Xin chào, $username!',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Vui lòng hoàn tất thông tin của bạn',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Form card
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Full name
                                CustomTextField(
                                  controller: _fullNameController,
                                  labelText: 'Họ và tên',
                                  hintText: 'Nhập họ và tên (tối thiểu 2 từ)',
                                  prefixIcon: Icons.person_outline,
                                  validator: Validators.validateFullName,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 16),

                                // Date of birth
                                CustomTextField(
                                  controller: TextEditingController(
                                    text:
                                        _selectedDate != null
                                            ? DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(_selectedDate!)
                                            : '',
                                  ),
                                  labelText: 'Ngày sinh',
                                  hintText: 'Chọn ngày sinh',
                                  prefixIcon: Icons.calendar_today_outlined,
                                  readOnly: true,
                                  onTap: _selectDate,
                                  validator: (value) {
                                    if (_selectedDate == null) {
                                      return 'Vui lòng chọn ngày sinh';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Phone
                                CustomTextField(
                                  controller: _phoneController,
                                  labelText: 'Số điện thoại',
                                  hintText: 'Nhập số điện thoại (10-11 số)',
                                  prefixIcon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: Validators.validatePhone,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 16),

                                // Gender
                                const Text(
                                  'Giới tính',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _GenderRadio(
                                        value: 'Nam',
                                        groupValue: _selectedGender,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedGender = value!;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _GenderRadio(
                                        value: 'Nữ',
                                        groupValue: _selectedGender,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedGender = value!;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _GenderRadio(
                                        value: 'Khác',
                                        groupValue: _selectedGender,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedGender = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Address
                                CustomTextField(
                                  controller: _addressController,
                                  labelText: 'Địa chỉ',
                                  hintText: 'Nhập địa chỉ (tối thiểu 5 ký tự)',
                                  prefixIcon: Icons.location_on_outlined,
                                  validator: Validators.validateAddress,
                                  maxLines: 3,
                                  textInputAction: TextInputAction.done,
                                ),
                                const SizedBox(height: 24),

                                // Submit button
                                Consumer<CustomerProvider>(
                                  builder: (context, customerProvider, child) {
                                    return CustomButton(
                                      text: 'Hoàn tất',
                                      onPressed: _handleSubmit,
                                      isLoading: customerProvider.isLoading,
                                    );
                                  },
                                ),
                              ],
                            ),
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
      ),
    );
  }

  /// Build progress indicator
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        children: [
          _ProgressStep(
            number: 1,
            label: 'Đăng ký',
            isActive: false,
            isCompleted: true,
          ),
          _ProgressLine(isCompleted: true),
          _ProgressStep(
            number: 2,
            label: 'Thông tin',
            isActive: true,
            isCompleted: false,
          ),
          _ProgressLine(isCompleted: false),
          _ProgressStep(
            number: 3,
            label: 'Hoàn tất',
            isActive: false,
            isCompleted: false,
          ),
        ],
      ),
    );
  }
}

/// Progress Step Widget
class _ProgressStep extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _ProgressStep({
    required this.number,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                isCompleted
                    ? AppTheme.successColor
                    : isActive
                    ? AppTheme.primaryColor
                    : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child:
                isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                      '$number',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                isActive
                    ? AppTheme.primaryColor
                    : isCompleted
                    ? AppTheme.successColor
                    : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

/// Progress Line Widget
class _ProgressLine extends StatelessWidget {
  final bool isCompleted;

  const _ProgressLine({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isCompleted ? AppTheme.successColor : Colors.grey.shade300,
      ),
    );
  }
}

/// Gender Radio Widget
class _GenderRadio extends StatelessWidget {
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _GenderRadio({
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppTheme.primaryColor,
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
