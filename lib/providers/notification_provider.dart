import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../features/order/data/order_api.dart';
import '../features/auth/data/auth_api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => n.isNew).length;

  // =========================
  // SETUP FIREBASE MESSAGING
  // =========================
  Future<void> initFirebase() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted FCM permission');

      // Sync ke backend
      AuthApi().syncFcmToken();

      // Listener ketika aplikasi di FOREGROUND (sedang dibuka)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        
        if (message.notification != null) {
          addNotification(AppNotification(
            title: message.notification!.title ?? 'Notifikasi Baru',
            message: message.notification!.body ?? '',
            time: DateTime.now().toString(),
            isNew: true,
          ));
        }
      });
    }
  }

  // =========================
  // ✅ BADGE PESANAN PENDING
  // =========================
  int _pendingOrderCount = 0;
  int get pendingOrderCount => _pendingOrderCount;

  Timer? _orderPollTimer;
  bool _pollingStarted = false;

  /// Start polling jumlah pesanan pending untuk mitra.
  /// Aman dipanggil berkali-kali (akan jalan sekali saja).
  void startPartnerOrderPolling(
    OrderApi api, {
    String status = 'pending',
    Duration interval = const Duration(seconds: 10),
  }) {
    if (_pollingStarted) return;
    _pollingStarted = true;

    Future<void> fetch() async {
      try {
        final items = await api.fetchPartnerOrders(status: status);
        final newCount = items.length;

        if (newCount != _pendingOrderCount) {
          _pendingOrderCount = newCount;
          notifyListeners();
        }
      } catch (_) {
        // ignore
      }
    }

    fetch(); // langsung update saat pertama kali
    _orderPollTimer = Timer.periodic(interval, (_) => fetch());
  }

  void stopPartnerOrderPolling() {
    _orderPollTimer?.cancel();
    _orderPollTimer = null;
    _pollingStarted = false;
  }

  // =========================
  // NOTIF LIST (kalau kamu pakai)
  // =========================
  void addNotification(AppNotification notif) {
    _notifications.insert(0, notif);
    notifyListeners();
  }

  void markAllAsRead() {
    for (final n in _notifications) {
      n.isNew = false;
    }
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
