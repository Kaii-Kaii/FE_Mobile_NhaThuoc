import 'package:flutter/foundation.dart';
import 'package:quan_ly_nha_thuoc/models/customer_model.dart';
import 'package:quan_ly_nha_thuoc/services/customer_service.dart';
import 'package:quan_ly_nha_thuoc/utils/constants.dart';
import 'package:quan_ly_nha_thuoc/utils/storage_helper.dart';

/// Customer Provider
/// Provider quản lý state thông tin khách hàng
class CustomerProvider with ChangeNotifier {
  final CustomerService _customerService = CustomerService();

  CustomerModel? _customer;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  CustomerModel? get customer => _customer;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasCustomerInfo => _customer != null;

  /// Initialize - Load customer data từ local storage
  Future<void> init() async {
    try {
      await loadCustomer();
    } catch (e) {
      debugPrint('Error initializing customer provider: $e');
    }
  }

  /// Load customer data từ local storage
  Future<void> loadCustomer() async {
    try {
      final customerData = StorageHelper.getObject(AppConstants.customerKey);
      if (customerData != null) {
        _customer = CustomerModel.fromJson(customerData);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading customer: $e');
    }
  }

  /// Tạo thông tin khách hàng
  Future<bool> createCustomer({
    required String hoTen,
    required DateTime ngaySinh,
    required String dienThoai,
    required String gioiTinh,
    required String diaChi,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Call API
      final customer = await _customerService.createCustomer(
        hoTen: hoTen,
        ngaySinh: ngaySinh,
        dienThoai: dienThoai,
        gioiTinh: gioiTinh,
        diaChi: diaChi,
      );

      // Save customer data
      _customer = customer;
      await StorageHelper.setObject(
        AppConstants.customerKey,
        customer.toJson(),
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    }
  }

  /// Get customer by ID
  Future<bool> getCustomer(int id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Call API
      final customer = await _customerService.getCustomer(id);

      // Save customer data
      _customer = customer;
      await StorageHelper.setObject(
        AppConstants.customerKey,
        customer.toJson(),
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    }
  }

  /// Update customer info
  Future<bool> updateCustomer(CustomerModel customer) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Call API
      await _customerService.updateCustomer(customer);

      // Update customer data
      _customer = customer;
      await StorageHelper.setObject(
        AppConstants.customerKey,
        customer.toJson(),
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    }
  }

  /// Clear customer data
  Future<void> clearCustomer() async {
    try {
      _customer = null;
      await StorageHelper.remove(AppConstants.customerKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing customer: $e');
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
