import 'dart:io';

/// Helper to load SVG from network with SSL certificate bypass (for dev/self-signed certs).
class SvgLoader {
  static Future<void> configureSvgHttpClient() {
    // Create an HttpClient that bypasses SSL verification for all requests
    HttpOverrides.global = _BypassSslHttpOverrides();
    return Future.value();
  }
}

/// Custom HttpOverrides to bypass SSL verification for all HTTP/HTTPS requests.
class _BypassSslHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}




