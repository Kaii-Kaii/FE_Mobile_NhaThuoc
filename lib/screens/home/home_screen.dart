import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_nha_thuoc/providers/auth_provider.dart';
import 'package:quan_ly_nha_thuoc/providers/customer_provider.dart';
import 'package:quan_ly_nha_thuoc/theme/app_theme.dart';
import 'package:quan_ly_nha_thuoc/utils/constants.dart';
import 'package:quan_ly_nha_thuoc/utils/snackbar_helper.dart';

/// Home Screen
/// Màn hình chủ với thông tin người dùng và chức năng đăng xuất
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Handle logout
  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text('Xác nhận đăng xuất'),
            content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      await authProvider.logout();
      await customerProvider.clearCustomer();

      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
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
              // App Bar
              _buildAppBar(context),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome section
                      _buildWelcomeSection(context),
                      const SizedBox(height: 24),

                      // User info card
                      _buildUserInfoCard(context),
                      const SizedBox(height: 16),

                      // Customer info card
                      _buildCustomerInfoCard(context),
                      const SizedBox(height: 24),

                      // Quick actions
                      _buildQuickActions(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build app bar
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medical_services,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Title
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhà Thuốc Medion',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Hệ thống quản lý',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Logout button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
    );
  }

  /// Build welcome section
  Widget _buildWelcomeSection(BuildContext context) {
    return Consumer2<AuthProvider, CustomerProvider>(
      builder: (context, authProvider, customerProvider, child) {
        final user = authProvider.user;
        final customer = customerProvider.customer;
        final displayName = customer?.hoTen ?? user?.tenDangNhap ?? 'User';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào,',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build user info card
  Widget _buildUserInfoCard(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        if (user == null) return const SizedBox.shrink();

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
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
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build customer info card
  Widget _buildCustomerInfoCard(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        final customer = customerProvider.customer;
        if (customer == null) return const SizedBox.shrink();

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
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
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
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
                if (customer.gioiTinh != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.wc_outlined,
                    label: 'Giới tính',
                    value: customer.gioiTinh!,
                  ),
                ],
                if (customer.diaChi != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Địa chỉ',
                    value: customer.diaChi!,
                  ),
                ],
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.badge_outlined,
                  label: 'Mã khách hàng',
                  value: '#${customer.maKH}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build quick actions
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chức năng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _QuickActionCard(
              icon: Icons.shopping_cart_outlined,
              title: 'Đặt hàng',
              color: AppTheme.primaryColor,
              onTap: () {
                SnackBarHelper.show(
                  context,
                  'Chức năng đang phát triển',
                  type: SnackBarType.info,
                );
              },
            ),
            _QuickActionCard(
              icon: Icons.history,
              title: 'Lịch sử',
              color: AppTheme.secondaryColor,
              onTap: () {
                SnackBarHelper.show(
                  context,
                  'Chức năng đang phát triển',
                  type: SnackBarType.info,
                );
              },
            ),
            _QuickActionCard(
              icon: Icons.local_offer_outlined,
              title: 'Ưu đãi',
              color: Colors.orange,
              onTap: () {
                SnackBarHelper.show(
                  context,
                  'Chức năng đang phát triển',
                  type: SnackBarType.info,
                );
              },
            ),
            _QuickActionCard(
              icon: Icons.support_agent_outlined,
              title: 'Hỗ trợ',
              color: Colors.green,
              onTap: () {
                SnackBarHelper.show(
                  context,
                  'Chức năng đang phát triển',
                  type: SnackBarType.info,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Info Row Widget
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
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLightColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
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

/// Quick Action Card Widget
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
