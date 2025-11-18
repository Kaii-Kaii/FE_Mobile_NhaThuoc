import 'package:quan_ly_nha_thuoc/models/customer_model.dart';
import 'package:quan_ly_nha_thuoc/services/api_service.dart';
import 'package:quan_ly_nha_thuoc/utils/constants.dart';

/// Customer Service
/// Service xử lý thông tin khách hàng
class CustomerService {
  final ApiService _apiService = ApiService();

  /// Tạo thông tin khách hàng
  ///
  /// [hoTen] - Họ và tên
  /// [ngaySinh] - Ngày sinh
  /// [dienThoai] - Số điện thoại
  /// [gioiTinh] - Giới tính
  /// [diaChi] - Địa chỉ
  ///
  /// Returns [CustomerModel] nếu thành công
  /// Throws [Exception] nếu thất bại
  Future<CustomerModel> createCustomer({
    required String hoTen,
    required DateTime ngaySinh,
    required String dienThoai,
    required String gioiTinh,
    required String diaChi,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.customerEndpoint,
        data: {
          'HoTen': hoTen,
          'NgaySinh': ngaySinh.toIso8601String(),
          'DienThoai': dienThoai,
          'GioiTinh': gioiTinh,
          'DiaChi': diaChi,
        },
      );

      // Parse response thành CustomerModel
      final customerData = response.data as Map<String, dynamic>;
      return CustomerModel.fromJson(customerData);
    } catch (e) {
      throw Exception(ApiService.handleError(e));
    }
  }

  /// Lấy thông tin khách hàng theo ID
  ///
  /// [id] - Mã khách hàng
  ///
  /// Returns [CustomerModel] nếu thành công
  /// Throws [Exception] nếu thất bại
  Future<CustomerModel> getCustomer(String id) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.customerEndpoint}/$id',
      );

      final customerData = response.data as Map<String, dynamic>;
      return CustomerModel.fromJson(customerData);
    } catch (e) {
      throw Exception(ApiService.handleError(e));
    }
  }

  /// Cập nhật thông tin khách hàng
  ///
  /// [customer] - Thông tin khách hàng cần cập nhật
  ///
  /// Returns [bool] true nếu thành công
  /// Throws [Exception] nếu thất bại
  Future<bool> updateCustomer(CustomerModel customer) async {
    try {
      await _apiService.put(
        '${AppConstants.customerEndpoint}/${customer.maKH}',
        data: {
          'HoTen': customer.hoTen,
          'NgaySinh': customer.ngaySinh?.toIso8601String(),
          'DienThoai': customer.dienThoai,
          'GioiTinh': customer.gioiTinh,
          'DiaChi': customer.diaChi,
        },
      );

      return true;
    } catch (e) {
      throw Exception(ApiService.handleError(e));
    }
  }
}
