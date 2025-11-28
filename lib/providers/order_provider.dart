import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  /// Tambah pesanan baru
  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  /// Hapus semua pesanan
  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }

  /// Update status pesanan (copy semua field biar data tidak hilang)
  void updateOrderStatus(int index, String newStatus) {
    if (index >= 0 && index < _orders.length) {
      final old = _orders[index];

      _orders[index] = Order(
        title: old.title,
        date: old.date,
        time: old.time,
        status: newStatus,
        image: old.image,
        location: old.location,
        detailAddress: old.detailAddress,
        plateNumber: old.plateNumber,
        username: old.username,
        phoneNumber: old.phoneNumber,
        bookingId: old.bookingId,
        carType: old.carType,
        price: old.price,
        servicePrice: old.servicePrice,
        tax: old.tax,
        discount: old.discount,
        total: old.total,
      );

      notifyListeners();
    }
  }
}
