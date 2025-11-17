import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/medicine_by_type.dart';
import '../models/medicine_detail.dart';
import '../utils/constants.dart';

class ThuocService {
  Future<List<MedicineByType>> getAll() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/Thuoc/ListThuocTonKho');
    try {
      http.Response resp;
      if (!kReleaseMode) {
        final ioc =
            HttpClient()
              ..badCertificateCallback =
                  (X509Certificate cert, String host, int port) => true;
        final client = IOClient(ioc);
        resp = await client.get(
          url,
          headers: {'Content-Type': 'application/json'},
        );
        client.close();
      } else {
        resp = await http.get(
          url,
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);

        if (body is List) {
          return body
              .map((e) => MedicineByType.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        if (body is Map<String, dynamic>) {
          final data = body['data'];
          if (data is List) {
            return data
                .map((e) => MedicineByType.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }

        throw Exception('Unexpected response format');
      }

      throw Exception('HTTP ${resp.statusCode}');
    } catch (e) {
      throw Exception('Error fetching medicines: $e');
    }
  }

  Future<List<MedicineByType>> getByLoai(String maLoai) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/Thuoc/ByLoai/$maLoai');
    try {
      http.Response resp;
      // In release builds we use the default client. During development (debug/profile)
      // allow connecting to a server with a self-signed certificate (emulator/local).
      if (!kReleaseMode) {
        final ioc =
            HttpClient()
              ..badCertificateCallback =
                  (X509Certificate cert, String host, int port) => true;
        final client = IOClient(ioc);
        resp = await client.get(
          url,
          headers: {'Content-Type': 'application/json'},
        );
        client.close();
      } else {
        resp = await http.get(
          url,
          headers: {'Content-Type': 'application/json'},
        );
      }
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);
        if (body is Map && body['status'] == 1) {
          final List data = body['data'] ?? [];
          return data
              .map((e) => MedicineByType.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Server returned status != 1');
        }
      } else {
        throw Exception('HTTP ${resp.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching medicines by type: $e');
    }
  }

  Future<MedicineDetail> getById(String maThuoc) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/Thuoc/$maThuoc');
    try {
      http.Response resp;
      if (!kReleaseMode) {
        final ioc =
            HttpClient()
              ..badCertificateCallback =
                  (X509Certificate cert, String host, int port) => true;
        final client = IOClient(ioc);
        resp = await client.get(
          url,
          headers: {'Content-Type': 'application/json'},
        );
        client.close();
      } else {
        resp = await http.get(
          url,
          headers: {'Content-Type': 'application/json'},
        );
      }
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);
        if (body is Map && body['status'] == 1) {
          final data = body['data'] as Map<String, dynamic>;
          return MedicineDetail.fromJson(data);
        } else {
          throw Exception('Server returned status != 1');
        }
      } else {
        throw Exception('HTTP ${resp.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching medicine detail: $e');
    }
  }
}
