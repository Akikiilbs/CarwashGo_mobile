import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart'; // untuk navigatorKey
import '../models/notification_model.dart';
import '../features/order/data/order_api.dart';
import '../features/auth/data/auth_api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => n.isNew).length;

  NotificationProvider() {
    _loadFromLocal();
  }

  // =========================
  // PERSISTEN LOCAL STORAGE
  // =========================
  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString('saved_notifications');
      if (savedStr != null) {
        final List<dynamic> listMap = jsonDecode(savedStr);
        _notifications = listMap.map((e) => AppNotification.fromMap(e)).toList();
        notifyListeners();
      }
    } catch (_) { }
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saveStr = jsonEncode(_notifications.map((e) => e.toMap()).toList());
      await prefs.setString('saved_notifications', saveStr);
    } catch (_) { }
  }

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
            route: message.data['route'], // rute khusus misal /menu atau /mitra-orders
          ));
        }
      });

      // =========================
      // OPSI B: DEEP LINKING HOOKS
      // =========================

      // 1. Aplikasi di BACKGROUND, lalu notifikasi diklik
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleDeepLink(message);
      });

      // 2. Aplikasi TERMINATED (mati), dibuka dari notifikasi
      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          // Delay sedikit agar tree build selesai
          Future.delayed(const Duration(milliseconds: 800), () {
            _handleDeepLink(message);
          });
        }
      });
      
      // Jika ada titipan notifikasi di shared_preferences dari background handler
      _loadFromLocal();
    }
  }

  void _handleDeepLink(RemoteMessage message) {
    debugPrint('Membuka aplikasi dari notifikasi: ${message.data}');
    
    // Opsi B: jika pesanan, buka halaman pesanan
    String? route = message.data['route'];
    
    // Default fallback jika tidak ada parameter route khusus dari backend,
    // kita setidaknya membawa user ke menu atau notifikasi.
    if (route != null && route.isNotEmpty) {
      navigatorKey.currentState?.pushNamed(route);
    } else {
      // Buka ke halaman notifikasi bawaan
      navigatorKey.currentState?.pushNamed('/notification');
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
    _saveToLocal();
    notifyListeners();
  }

  void markAllAsRead() {
    for (final n in _notifications) {
      n.isNew = false;
    }
    _saveToLocal();
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _saveToLocal();
    notifyListeners();
  }
}
