import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class NetworkImageWithCertHandling extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  const NetworkImageWithCertHandling({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  @override
  State<NetworkImageWithCertHandling> createState() =>
      _NetworkImageWithCertHandlingState();
}

class _NetworkImageWithCertHandlingState
    extends State<NetworkImageWithCertHandling> {
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
        final ioc =
            HttpClient()
              ..badCertificateCallback =
                  (X509Certificate cert, String host, int port) => true;
        final client = IOClient(ioc);
        final resp = await client.get(Uri.parse(widget.imageUrl));
        client.close();
        if (!mounted) return;
        if (resp.statusCode == 200) {
          setState(() {
            _bytes = resp.bodyBytes;
            _loading = false;
          });
          return;
        }
      } else {
        final resp = await http.get(Uri.parse(widget.imageUrl));
        if (!mounted) return;
        if (resp.statusCode == 200) {
          setState(() {
            _bytes = resp.bodyBytes;
            _loading = false;
          });
          return;
        }
      }
      if (mounted) {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_error || _bytes == null) {
      return const Icon(Icons.broken_image, color: Color(0xFF03A297));
    }
    return Image.memory(_bytes!, fit: widget.fit);
  }
}
