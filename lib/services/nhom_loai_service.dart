import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nhom_loai_model.dart';

class NhomLoaiService {
  final String baseUrl = "https://localhost:7283/api/NhomLoai";

  Future<List<NhomLoai>> getAll() async {
    final url = Uri.parse("$baseUrl/WithLoai");
    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception("Không load được nhóm loại");
    }

    final body = json.decode(res.body);
    List data = body['data'];

    return data.map((x) => NhomLoai.fromJson(x)).toList();
  }
}
