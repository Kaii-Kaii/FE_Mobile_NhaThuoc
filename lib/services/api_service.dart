import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:quan_ly_nha_thuoc/utils/constants.dart';
import 'package:quan_ly_nha_thuoc/utils/storage_helper.dart';

/// Callback để xử lý khi token hết hạn
typedef OnTokenExpired = void Function();

/// API Service Base
/// Service cơ bản để xử lý các API calls
class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;

  /// Callback được gọi khi token hết hạn (401)
  static OnTokenExpired? onTokenExpired;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _initializeDio();
  }

  /// Khởi tạo Dio với config
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Bypass SSL certificate validation cho self-signed certificate
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
    );

    // Add interceptors để log requests và responses, thêm token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Thêm Authorization header nếu có token
          final token = StorageHelper.getString(AppConstants.tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
          print('📦 DATA: ${options.data}');
          print('🔑 HAS TOKEN: ${token != null && token.isNotEmpty}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ RESPONSE[${response.statusCode}] => DATA: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print(
            '❌ ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}',
          );
          print('📛 ERROR DATA: ${error.response?.data}');

          // Xử lý 401 Unauthorized - Token hết hạn hoặc không hợp lệ
          if (error.response?.statusCode == 401) {
            _handleUnauthorized();
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// Xử lý khi nhận được lỗi 401
  void _handleUnauthorized() {
    // Xóa token đã lưu
    StorageHelper.remove(AppConstants.tokenKey);
    StorageHelper.remove(AppConstants.userKey);

    // Gọi callback để app xử lý (redirect về login)
    if (onTokenExpired != null) {
      onTokenExpired!();
    }
  }

  /// Cập nhật token mới
  static Future<void> setToken(String? token) async {
    if (token != null && token.isNotEmpty) {
      await StorageHelper.setString(AppConstants.tokenKey, token);
    } else {
      await StorageHelper.remove(AppConstants.tokenKey);
    }
  }

  /// Lấy token hiện tại
  static String? getToken() {
    return StorageHelper.getString(AppConstants.tokenKey);
  }

  /// Xóa token
  static Future<void> clearToken() async {
    await StorageHelper.remove(AppConstants.tokenKey);
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Xử lý error từ API
  static String handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Kết nối timeout. Vui lòng thử lại.';

        case DioExceptionType.badResponse:
          // Xử lý 401 Unauthorized
          if (error.response?.statusCode == 401) {
            return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
          }
          // Xử lý 403 Forbidden
          if (error.response?.statusCode == 403) {
            return 'Bạn không có quyền truy cập chức năng này.';
          }
          // Xử lý error response từ server
          if (error.response?.data != null) {
            // Nếu response là string
            if (error.response!.data is String) {
              return error.response!.data as String;
            }
            // Nếu response là JSON object
            if (error.response!.data is Map) {
              final data = error.response!.data as Map<String, dynamic>;
              // Thử lấy message từ các key thường dùng
              return data['message'] ??
                  data['error'] ??
                  data['Message'] ??
                  data['Error'] ??
                  AppConstants.serverError;
            }
          }
          return 'Lỗi từ server: ${error.response?.statusCode}';

        case DioExceptionType.cancel:
          return 'Yêu cầu đã bị hủy';

        case DioExceptionType.connectionError:
          return AppConstants.networkError;

        case DioExceptionType.badCertificate:
          return 'Lỗi chứng chỉ SSL';

        case DioExceptionType.unknown:
          if (error.message?.contains('SocketException') ?? false) {
            return AppConstants.networkError;
          }
          return AppConstants.unknownError;
      }
    }

    return error.toString();
  }
}
