import 'dart:async';

import 'package:app_links/app_links.dart';

class DeepLinkService {
  DeepLinkService._();

  static final DeepLinkService instance = DeepLinkService._();

  final StreamController<Uri> _controller = StreamController.broadcast();
  AppLinks? _appLinks;
  bool _initialized = false;

  Stream<Uri> get stream => _controller.stream;

  void init() {
    if (_initialized) return;
    _initialized = true;

    _appLinks = AppLinks();

    _appLinks!.uriLinkStream.listen((uri) {
      if (uri != null) {
        _controller.add(uri);
      }
    });

    _appLinks!.getInitialLink().then((uri) {
      if (uri != null) {
        _controller.add(uri);
      }
    });
  }
}
