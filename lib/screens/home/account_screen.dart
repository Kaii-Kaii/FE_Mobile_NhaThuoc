import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_nha_thuoc/models/customer_model.dart';
import 'package:quan_ly_nha_thuoc/models/user_model.dart';
import 'package:quan_ly_nha_thuoc/providers/auth_provider.dart';
import 'package:quan_ly_nha_thuoc/providers/customer_provider.dart';
import 'package:quan_ly_nha_thuoc/theme/app_theme.dart';
import 'package:quan_ly_nha_thuoc/utils/constants.dart';
import 'package:quan_ly_nha_thuoc/widgets/custom_button.dart';

/// Account Screen
/// Hiển thị thông tin tài khoản hoặc yêu cầu đăng nhập
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _ensureCustomerLoaded();
    }
  }

  Future<void> _ensureCustomerLoaded() async {
    final authProvider = context.read<AuthProvider>();
    final customerProvider = context.read<CustomerProvider>();

    if (!authProvider.isLoggedIn) return;
    if (customerProvider.hasCustomerInfo) return;

    final customerId = authProvider.user?.maKhachHang;
    if (customerId != null) {
      await customerProvider.getCustomer(customerId);
    }
  }

  Future<void> _refreshCustomerInfo() async {
    final authProvider = context.read<AuthProvider>();
    final customerProvider = context.read<CustomerProvider>();

    if (!authProvider.isLoggedIn) return;

    final customerId = authProvider.user?.maKhachHang;
    if (customerId != null) {
      await customerProvider.getCustomer(customerId);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final authProvider = context.read<AuthProvider>();
    final customerProvider = context.read<CustomerProvider>();

    await authProvider.logout();
    await customerProvider.clearCustomer();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bạn đã đăng xuất thành công.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Consumer2<AuthProvider, CustomerProvider>(
        builder: (context, authProvider, customerProvider, child) {
          if (!authProvider.isLoggedIn) {
            return _buildLoggedOutView();
          }

          final isLoading =
              customerProvider.isLoading && !customerProvider.hasCustomerInfo;

          return RefreshIndicator(
            onRefresh: _refreshCustomerInfo,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                _buildWelcomeCard(authProvider.user),
                const SizedBox(height: 20),
                _buildAccountInfoCard(authProvider.user),
                const SizedBox(height: 20),
                if (isLoading) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ] else ...[
                  _buildCustomerInfoSection(
                    customerProvider.customer,
                    customerProvider.errorMessage,
                  ),
                ],
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Đăng xuất',
                  icon: Icons.logout,
                  color: AppTheme.errorColor,
                  onPressed: _handleLogout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      title: const Text('Tài khoản'),
      centerTitle: true,
    );
  }

  Widget _buildWelcomeCard(UserModel? user) {
    final displayName = user?.tenDangNhap ?? 'Khách hàng';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF023350), Color(0xFF02294A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào,',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Quản lý tài khoản và thông tin cá nhân của bạn tại đây.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(UserModel? user) {
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_circle,
                    color: AppTheme.primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Thông tin tài khoản',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Tên đăng nhập',
              value: user.tenDangNhap,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.badge_outlined,
              label: 'Mã tài khoản',
              value: '#${user.maTK}',
            ),
            if (user.maKhachHang != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.confirmation_number,
                label: 'Mã khách hàng',
                value: '#${user.maKhachHang}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoSection(
    CustomerModel? customer,
    String? errorMessage,
  ) {
    if (customer != null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.successColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Thông tin cá nhân',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              _InfoRow(
                icon: Icons.person_outline,
                label: 'Họ và tên',
                value: customer.hoTen,
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Số điện thoại',
                value: customer.dienThoai,
              ),
              if (customer.ngaySinh != null) ...[
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.cake_outlined,
                  label: 'Ngày sinh',
                  value: DateFormat('dd/MM/yyyy').format(customer.ngaySinh!),
                ),
              ],
              if (customer.gioiTinh != null &&
                  customer.gioiTinh!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.wc_outlined,
                  label: 'Giới tính',
                  value: customer.gioiTinh!,
                ),
              ],
              if (customer.diaChi != null && customer.diaChi!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Địa chỉ',
                  value: customer.diaChi!,
                ),
              ],
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.tag_outlined,
                label: 'Mã khách hàng',
                value: '#${customer.maKH}',
              ),
              const SizedBox(height: 24),
              CustomOutlineButton(
                text: 'Cập nhật thông tin',
                icon: Icons.edit,
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed(AppConstants.customerInfoRoute);
                },
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              color: AppTheme.primaryColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Bạn chưa có thông tin khách hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ??
                  'Vui lòng tạo mới để sử dụng đầy đủ chức năng của ứng dụng.',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Tạo thông tin khách hàng',
              icon: Icons.person_add_alt,
              onPressed: () {
                Navigator.of(context).pushNamed(AppConstants.customerInfoRoute);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedOutView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF023350), Color(0xFF02294A)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chào mừng bạn đến với Nhà Thuốc Medion',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Đăng nhập hoặc tạo tài khoản để quản lý đơn hàng và nhận ưu đãi dành riêng cho bạn.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Đăng nhập',
          icon: Icons.login,
          onPressed: () {
            Navigator.of(context).pushNamed(
              AppConstants.loginRoute,
              arguments: {"popOnSuccess": true},
            );
          },
        ),
        const SizedBox(height: 16),
        CustomOutlineButton(
          text: 'Tạo tài khoản',
          icon: Icons.person_add,
          onPressed: () {
            Navigator.of(context).pushNamed(AppConstants.registerRoute);
          },
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
