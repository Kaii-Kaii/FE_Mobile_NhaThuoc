import 'dart:convert';
import 'dart:io';

/// Standalone test script to GET /NhomLoai
/// Run with: dart run scripts/test_category_group.dart
Future<void> main() async {
  final hosts = [
    'https://localhost:7283/api/NhomLoai',
    'https://kltn-l679.onrender.com/api/NhomLoai',
  ];

  for (var h in hosts) {
    print('\nTrying $h');
    final uri = Uri.parse(h);

    final httpClient =
        HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;

    try {
      final request = await httpClient.getUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      final response = await request.close();

      final body = await utf8.decoder.bind(response).join();
      print('Status: ${response.statusCode}');
      // Print only first 1000 chars to avoid huge logs
      print(
        'Body (truncated): ${body.length > 1000 ? "${body.substring(0, 1000)}..." : body}',
      );

      if (response.statusCode == 200) {
        final parsed = json.decode(body);
        if (parsed is Map && parsed['data'] is List) {
          final list = parsed['data'] as List;
          print('Parsed ${list.length} items:');
          for (var item in list) {
            print(
              ' - ${item['maNhomLoai'] ?? item['MaNhomLoai']} : ${item['tenNhomLoai'] ?? item['TenNhomLoai']}',
            );
          }
        } else if (parsed is List) {
          print('Parsed list with ${parsed.length} items');
        } else {
          print('Unexpected JSON shape');
        }
        httpClient.close(force: true);
        return;
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error calling $h: $e');
    } finally {
      httpClient.close(force: true);
    }
  }

  print('\nBoth hosts failed.');
}
