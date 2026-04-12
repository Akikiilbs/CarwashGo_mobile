import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransCheckoutPage extends StatefulWidget {
  final String checkoutUrl;
  final bool useExternalBrowser;

  const MidtransCheckoutPage({
    super.key,
    required this.checkoutUrl,
    this.useExternalBrowser = false,
  });

  @override
  State<MidtransCheckoutPage> createState() => _MidtransCheckoutPageState();
}

class _MidtransCheckoutPageState extends State<MidtransCheckoutPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  late final bool _webViewSupported;

  static bool _isWebViewUnsupported() {
    if (kIsWeb) return true;
    return !(Platform.isAndroid || Platform.isIOS || Platform.isMacOS);
  }

  @override
  void initState() {
    super.initState();

    _webViewSupported =
        !widget.useExternalBrowser && !_isWebViewUnsupported();

    if (!_webViewSupported) {
      _openExternalIfNeeded();
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            final url = request.url.toLowerCase();

            if (url.startsWith('carwashgo://payment/finish')) {
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }

            if (url.contains('transaction_status=settlement') ||
                url.contains('transaction_status=capture') ||
                url.contains('status_code=200')) {
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }

            if (url.contains('transaction_status=deny') ||
                url.contains('transaction_status=cancel') ||
                url.contains('transaction_status=expire')) {
              Navigator.pop(context, false);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  Future<void> _openExternalIfNeeded() async {
    if (!widget.useExternalBrowser) return;
    final uri = Uri.parse(widget.checkoutUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (!_webViewSupported) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Checkout Midtrans',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WebView tidak didukung di platform ini.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text(
                'Gunakan browser eksternal untuk melanjutkan pembayaran, '
                'lalu kembali ke aplikasi dan tekan tombol cek status.',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final uri = Uri.parse(widget.checkoutUrl);
                    if (!await launchUrl(uri,
                        mode: LaunchMode.externalApplication)) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gagal membuka browser'),
                        ),
                      );
                    }
                  },
                  child: const Text('Buka di Browser'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Saya Sudah Bayar'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout Midtrans',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
