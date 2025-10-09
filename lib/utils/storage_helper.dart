import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage Helper
/// Helper class để làm việc với SharedPreferences
class StorageHelper {
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'StorageHelper chưa được khởi tạo. Gọi StorageHelper.init() trước.',
      );
    }
    return _prefs!;
  }

  /// Lưu string
  static Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  /// Lấy string
  static String? getString(String key) {
    return prefs.getString(key);
  }

  /// Lưu object dưới dạng JSON
  static Future<bool> setObject(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    return await setString(key, jsonString);
  }

  /// Lấy object từ JSON
  static Map<String, dynamic>? getObject(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Lưu boolean
  static Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  /// Lấy boolean
  static bool? getBool(String key) {
    return prefs.getBool(key);
  }

  /// Lưu int
  static Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  /// Lấy int
  static int? getInt(String key) {
    return prefs.getInt(key);
  }

  /// Xóa một key
  static Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  /// Xóa tất cả data
  static Future<bool> clear() async {
    return await prefs.clear();
  }

  /// Kiểm tra key có tồn tại không
  static bool containsKey(String key) {
    return prefs.containsKey(key);
  }
}
