// lib/providers/order_provider.dart

import 'package:flutter/material.dart';
import '../features/order/data/order_api.dart';
import '../features/order/models/simple_api_response.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];

  final OrderApi _orderApi = OrderApi();
  bool _loading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _loading;
  String? get errorMessage => _error;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

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

  // ============================================================
  // ✅ REMOTE (API) — CUSTOMER
  // ============================================================
  Future<void> loadCustomerOrders({String? status}) async {
    _setError(null);
    _setLoading(true);
    try {
      final items = await _orderApi.fetchCustomerOrders(status: status);
      _orders
        ..clear()
        ..addAll(items.map(_mapApiOrderToUiForCustomer));
    } catch (e) {
      _setError('Gagal mengambil pesanan. ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // ✅ REMOTE (API) — PARTNER
  // ============================================================
  Future<void> loadPartnerOrders({String? status}) async {
    _setError(null);
    _setLoading(true);
    try {
      final items = await _orderApi.fetchPartnerOrders(status: status);
      _orders
        ..clear()
        ..addAll(items.map(_mapApiOrderToUiForPartner));
    } catch (e) {
      _setError('Gagal mengambil pesanan mitra. ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<SimpleApiResponse> partnerAccept(int orderId) async {
    final res = await _orderApi.partnerAccept(orderId);
    return res;
  }

  Future<SimpleApiResponse> partnerReject(int orderId) async {
    final res = await _orderApi.partnerReject(orderId);
    return res;
  }

  Future<SimpleApiResponse> partnerUpdateStatus({
    required int orderId,
    required String status,
  }) async {
    final res = await _orderApi.partnerUpdateStatus(orderId: orderId, status: status);
    return res;
  }

  // ============================================================
  // ✅ Mapper: API -> UI Order
  // ============================================================
  Order _mapApiOrderToUiForCustomer(Map<String, dynamic> o) {
    final partner = (o['partner'] is Map) ? Map<String, dynamic>.from(o['partner']) : null;
    final title = partner?['business_name']?.toString() ?? 'Mitra';

    final date = (o['scheduled_date'] ?? '').toString().isNotEmpty
        ? (o['scheduled_date'] ?? '').toString()
        : (o['created_at'] ?? '').toString();

    final rawTime = (o['scheduled_time'] ?? '').toString();
    final time = rawTime.length >= 5 ? rawTime.substring(0, 5) : rawTime;

    final totalAmount = (o['total_amount'] is num)
        ? (o['total_amount'] as num).toInt()
        : int.tryParse(o['total_amount']?.toString() ?? '') ?? 0;

    return Order(
      mitraId: partner?['id']?.toString(),
      title: title,
      date: date,
      time: time,
      status: (o['status'] ?? '').toString(),
      image: 'assets/images/on1.png',
      location: (o['address'] ?? '').toString(),
      detailAddress: '',
      plateNumber: (o['plate_number'] ?? '').toString(),
      username: (o['customer']?['name'] ?? '').toString(),
      phoneNumber: '',
      bookingId: (o['id'] ?? '').toString(),
      carType: (o['vehicle_model'] ?? '').toString().isNotEmpty
          ? '${(o['vehicle_brand'] ?? '').toString()} ${(o['vehicle_model'] ?? '').toString()}'.trim()
          : 'Vehicle',
      price: 0,
      servicePrice: totalAmount,
      tax: 0,
      discount: 0,
      total: totalAmount,
    );
  }

  Order _mapApiOrderToUiForPartner(Map<String, dynamic> o) {
    final customer = (o['customer'] is Map) ? Map<String, dynamic>.from(o['customer']) : null;
    final title = customer?['name']?.toString() ?? 'Customer';

    final date = (o['scheduled_date'] ?? '').toString().isNotEmpty
        ? (o['scheduled_date'] ?? '').toString()
        : (o['created_at'] ?? '').toString();

    final rawTime = (o['scheduled_time'] ?? '').toString();
    final time = rawTime.length >= 5 ? rawTime.substring(0, 5) : rawTime;

    final totalAmount = (o['total_amount'] is num)
        ? (o['total_amount'] as num).toInt()
        : int.tryParse(o['total_amount']?.toString() ?? '') ?? 0;

    return Order(
      mitraId: (o['partner_id'] ?? '').toString(),
      title: title,
      date: date,
      time: time,
      status: (o['status'] ?? '').toString(),
      image: 'assets/images/on1.png',
      location: (o['address'] ?? '').toString(),
      detailAddress: '',
      plateNumber: (o['plate_number'] ?? '').toString(),
      username: title,
      phoneNumber: '',
      bookingId: (o['id'] ?? '').toString(),
      carType: (o['vehicle_model'] ?? '').toString().isNotEmpty
          ? '${(o['vehicle_brand'] ?? '').toString()} ${(o['vehicle_model'] ?? '').toString()}'.trim()
          : 'Vehicle',
      price: 0,
      servicePrice: totalAmount,
      tax: 0,
      discount: 0,
      total: totalAmount,
    );
  }
}
