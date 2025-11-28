import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;

  // ✅ Tambah notifikasi baru
  void addNotification(AppNotification notif) {
    _notifications.insert(0, notif); // Ditambah ke posisi paling atas
    notifyListeners();
  }

  // ✅ Tandai satu notifikasi sebagai sudah dibaca
  void markAsRead(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications[index].isNew = false;
      notifyListeners();
    }
  }

  // ✅ Tandai semua notifikasi sebagai sudah dibaca
  void markAllAsRead() {
    for (var notif in _notifications) {
      notif.isNew = false;
    }
    notifyListeners();
  }

  // ✅ Hapus semua notifikasi (misalnya saat logout)
  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
