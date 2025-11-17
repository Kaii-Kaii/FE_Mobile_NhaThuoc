import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../services/thuoc_service.dart';
import '../../models/medicine_by_type.dart';
import 'medicine_detail_screen.dart';

class MedicinesByTypeScreen extends StatefulWidget {
  final String maLoai;
  final String tenLoai;
  const MedicinesByTypeScreen({Key? key, required this.maLoai, required this.tenLoai}) : super(key: key);

  @override
  State<MedicinesByTypeScreen> createState() => _MedicinesByTypeScreenState();
}

class _MedicinesByTypeScreenState extends State<MedicinesByTypeScreen> {
  final ThuocService _service = ThuocService();
  bool _loading = true;
  String? _error;
  List<MedicineByType> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final items = await _service.getByLoai(widget.maLoai);
      setState(() { _items = items; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tenLoai),
        backgroundColor: const Color(0xFF023350),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Lỗi: $_error'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final m = _items[i];
                    return ListTile(
                      leading: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                        ),
            child: (m.urlAnh != null && m.urlAnh!.isNotEmpty)
              ? Builder(builder: (_) {
                final s = m.urlAnh!.trim();
                // If API returns a full URL, use it; otherwise build Cloudinary URL
                final imageUrl = (s.startsWith('http://') || s.startsWith('https://'))
                  ? s
                  : 'https://res.cloudinary.com/dmu0nknhg/image/upload/v1761064479/thuoc_images/thuoc/$s';
                                return NetworkImageWithCertHandling(imageUrl: imageUrl, fit: BoxFit.cover);
                })
              : const Icon(Icons.medication, color: Color(0xFF03A297)),
                      ),
                      title: Text(m.tenThuoc),
                      subtitle: Text(m.tenNCC ?? ''),
                      trailing: Text('${m.donGiaSi ?? 0} đ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => MedicineDetailScreen(maThuoc: m.maThuoc)));
                      },
                    );
                  },
                ),
    );
  }
}

// Small helper widget to load network images but accept self-signed certs in debug/profile builds.
class NetworkImageWithCertHandling extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  const NetworkImageWithCertHandling({Key? key, required this.imageUrl, this.fit = BoxFit.cover}) : super(key: key);

  @override
  State<NetworkImageWithCertHandling> createState() => _NetworkImageWithCertHandlingState();
}

class _NetworkImageWithCertHandlingState extends State<NetworkImageWithCertHandling> {
  Uint8List? _bytes;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _fetchBytes();
  }

  Future<void> _fetchBytes() async {
    try {
      if (!kReleaseMode) {
        final ioc = HttpClient()
          ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        final client = IOClient(ioc);
        final resp = await client.get(Uri.parse(widget.imageUrl));
        client.close();
        if (resp.statusCode == 200) {
          setState(() { _bytes = resp.bodyBytes; _loading = false; });
          return;
        }
      } else {
        final resp = await http.get(Uri.parse(widget.imageUrl));
        if (resp.statusCode == 200) {
          setState(() { _bytes = resp.bodyBytes; _loading = false; });
          return;
        }
      }
      setState(() { _error = true; _loading = false; });
    } catch (e) {
      setState(() { _error = true; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()));
    if (_error || _bytes == null) return const Icon(Icons.broken_image, color: Color(0xFF03A297));
    return Image.memory(_bytes!, fit: widget.fit);
  }
}
