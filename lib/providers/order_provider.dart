// lib/providers/order_provider.dart

import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  // ✅ TAMBAH PESANAN BARU (DARI USER)
  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  // ✅ AMBIL PESANAN BERDASARKAN MITRA (AMAN WALAUPUN mitraId NULL)
  List<Order> getOrdersByMitra(String mitraId) {
    return _orders.where((o) => o.mitraId == mitraId).toList();
  }

  // ✅ UPDATE STATUS PESANAN BERDASARKAN bookingId (LEBIH AMAN DARI INDEX)
  void updateOrderStatusByBookingId(String bookingId, String newStatus) {
    final index = _orders.indexWhere((o) => o.bookingId == bookingId);

    if (index != -1) {
      final old = _orders[index];

      _orders[index] = old.copyWith(
        status: newStatus,
      );

      notifyListeners();
    }
  }

  // ✅ OPSIONAL: MASIH BOLEH PAKE INDEX JIKA KAMU MAU
  void updateOrderStatus(int index, String newStatus) {
    if (index >= 0 && index < _orders.length) {
      final old = _orders[index];

      _orders[index] = old.copyWith(
        status: newStatus,
      );

      notifyListeners();
    }
  }

  // ✅ HAPUS SEMUA PESANAN (DEBUG / RESET)
  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
